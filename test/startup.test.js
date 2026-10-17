'use strict';
const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),os=require('node:os'),path=require('node:path'),net=require('node:net'),{spawn,spawnSync}=require('node:child_process');
const root=path.join(__dirname,'..');
test('Windows 无 PATH Node、无残留服务：双击脚本解包并在五分钟内提供 UI', {skip:process.platform!=='win32',timeout:120000},async()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'fde-cold-')),server=net.createServer();await new Promise(r=>server.listen(0,'127.0.0.1',r));let port=server.address().port;await new Promise(r=>server.close(r));
 const windows=process.env.SystemRoot||'C:\\Windows',env={...process.env,PATH:path.join(windows,'System32')+';'+windows,PORT:String(port),FDE_NO_BROWSER:'1',FDE_SMOKE_TEST:'1',FDE_RUNTIME_DIR:path.join(dir,'runtime'),FDE_EDIT_FILE:path.join(dir,'edits.json')};
 assert.notEqual(spawnSync('where.exe',['node'],{env}).status,0,'测试环境中不得从 PATH 找到 node');
 let proc=spawn(path.join(windows,'System32','cmd.exe'),['/c','start.cmd'],{cwd:root,env,stdio:'pipe'}),log='';proc.stdout.on('data',x=>log+=x);proc.stderr.on('data',x=>log+=x);let begun=Date.now();
 try{let ready=false;for(let i=0;i<100;i++){try{let r=await fetch('http://127.0.0.1:'+port+'/api/health');if(r.ok){ready=true;break}}catch{}if(proc.exitCode!==null)break;await new Promise(r=>setTimeout(r,300))}
 assert.ok(ready,'冷启动未成功: '+log);assert.ok(Date.now()-begun<300000);assert.ok(fs.existsSync(path.join(dir,'runtime','node.exe')));assert.ok(fs.existsSync(path.join(dir,'runtime','LICENSE')));
 let r=await fetch('http://127.0.0.1:'+port+'/');assert.equal(r.status,200);assert.match(await r.text(),/人力成本/);
 }finally{if(proc.exitCode===null){proc.stdin.write('\n');await Promise.race([new Promise(r=>proc.once('close',r)),new Promise(r=>setTimeout(r,12000))]);if(proc.exitCode===null)proc.kill()}proc.stdout.destroy();proc.stderr.destroy();fs.rmSync(dir,{recursive:true,force:true,maxRetries:10,retryDelay:200})}
});
