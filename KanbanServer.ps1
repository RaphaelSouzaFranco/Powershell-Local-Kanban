$port=8080
$url="http://localhost:$port/"
$scriptDir=$PSScriptRoot
if([string]::IsNullOrEmpty($scriptDir)){$scriptDir=(Get-Location).Path}
$jsonFile=Join-Path $scriptDir "kanban_data.json"

$htmlContent=@'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PowerShell Kanban</title>
<script src="https://cdn.tailwindcss.com"></script>
<style>.kanban-col{min-height:250px}.drag-over{background-color:rgba(0,0,0,0.05);border-radius:0.5rem;}</style>
</head>
<body class="bg-slate-100 text-slate-800 font-sans p-4 md:p-8">
<div class="max-w-7xl mx-auto">
<h1 class="text-3xl font-extrabold mb-8 text-center text-slate-700">&#128204; PowerShell Kanban</h1>
<div class="bg-white p-6 rounded-xl shadow-sm border border-slate-200 mb-8">
<form id="cardForm" class="grid grid-cols-1 md:grid-cols-4 gap-4">
<input type="hidden" id="cardId">
<div class="md:col-span-2"><label class="block text-sm font-semibold mb-1 text-slate-600">T&iacute;tulo</label><input type="text" id="title" required class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500"></div>
<div class="md:col-span-2"><label class="block text-sm font-semibold mb-1 text-slate-600">Projeto</label><input type="text" id="project" required class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500"></div>

<div><label class="block text-sm font-semibold mb-1 text-slate-600">Data</label><input type="date" id="date" required class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500"></div>
<div><label class="block text-sm font-semibold mb-1 text-slate-600">In&iacute;cio</label><input type="time" id="startTime" class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500" onchange="calcHours()"></div>
<div><label class="block text-sm font-semibold mb-1 text-slate-600">T&eacute;rmino</label><input type="time" id="endTime" class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500" onchange="calcHours()"></div>
<div><label class="block text-sm font-semibold mb-1 text-slate-600">Horas Gastas</label><input type="text" id="hours" readonly placeholder="Calculado..." class="w-full border rounded p-2 bg-slate-100 text-slate-500 outline-none"></div>

<div class="md:col-span-4"><label class="block text-sm font-semibold mb-1 text-slate-600">Coluna</label><select id="column" class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500"><option value="backlog">Backlog</option><option value="desenvolvendo">Desenvolvendo</option><option value="concluido">Conclu&iacute;do</option></select></div>
<div class="md:col-span-4"><label class="block text-sm font-semibold mb-1 text-slate-600">Descri&ccedil;&atilde;o</label><textarea id="description" rows="2" class="w-full border rounded p-2 outline-none focus:ring-2 focus:ring-blue-500"></textarea></div>
<div class="md:col-span-4"><button type="submit" class="w-full bg-blue-600 text-white font-bold py-2 rounded hover:bg-blue-700">Salvar Card</button></div>
</form>
</div>
<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
<div class="bg-slate-200 rounded-xl p-4 shadow-inner"><h2 class="text-lg font-bold mb-4 text-slate-700 uppercase tracking-wide">Backlog</h2><div id="col-backlog" class="kanban-col space-y-4" ondrop="drop(event, 'backlog')" ondragover="allowDrop(event)"></div></div>
<div class="bg-blue-50 rounded-xl p-4 shadow-inner border border-blue-100"><h2 class="text-lg font-bold mb-4 text-blue-800 uppercase tracking-wide">Desenvolvendo</h2><div id="col-desenvolvendo" class="kanban-col space-y-4" ondrop="drop(event, 'desenvolvendo')" ondragover="allowDrop(event)"></div></div>
<div class="bg-green-50 rounded-xl p-4 shadow-inner border border-green-100"><h2 class="text-lg font-bold mb-4 text-green-800 uppercase tracking-wide">Conclu&iacute;do</h2><div id="col-concluido" class="kanban-col space-y-4" ondrop="drop(event, 'concluido')" ondragover="allowDrop(event)"></div></div>
</div>
</div>
<script>
let cards=[];
async function loadData(){
try{const r=await fetch('/api/data');cards=await r.json();if(!Array.isArray(cards))cards=[];render();}catch(e){}
}
async function saveData(){
try{await fetch('/api/data',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(cards)});}catch(e){}
}
function calcHours(){
const s=document.getElementById('startTime').value;
const e=document.getElementById('endTime').value;
if(s && e){
const [h1,m1]=s.split(':').map(Number);
const [h2,m2]=e.split(':').map(Number);
let diff=(h2*60+m2)-(h1*60+m1);
if(diff<0) diff+=24*60;
const hrs=Math.floor(diff/60);
const mins=diff%60;
document.getElementById('hours').value=`${hrs}h ${mins}m`;
}else{document.getElementById('hours').value='';}
}
function render(){
['backlog','desenvolvendo','concluido'].forEach(col=>{document.getElementById('col-'+col).innerHTML='';});
cards.forEach(c=>{
const el=document.createElement('div');
el.className='bg-white p-4 rounded-lg shadow-sm border-l-4 cursor-grab hover:shadow-md relative group ';
el.className+=(c.column==='backlog'?'border-slate-500':c.column==='desenvolvendo'?'border-blue-500':'border-green-500');
el.draggable=true; el.id=c.id;
el.ondragstart=(e)=>{e.dataTransfer.setData("id",c.id);setTimeout(()=>el.classList.add('opacity-50'),0);};
el.ondragend=()=>el.classList.remove('opacity-50');

const dataFormatada=c.date?c.date.split('-').reverse().join('/'):'Sem data';
el.innerHTML=`
<div class="flex justify-between items-start mb-2"><h3 class="font-bold text-slate-800 leading-tight pr-2">${c.title}</h3>
<div class="flex space-x-2"><button onclick="editCard('${c.id}')" class="text-slate-400 hover:text-blue-600">&#9999;&#65039;</button><button onclick="delCard('${c.id}')" class="text-slate-400 hover:text-red-600">&#128465;&#65039;</button></div></div>
<div class="text-xs font-semibold text-slate-500 mb-1">&#128193; ${c.project}</div>
<div class="text-xs text-slate-400 font-medium mb-3">&#128197; ${dataFormatada} | &#9200; ${c.startTime||'--'} &agrave;s ${c.endTime||'--'}</div>
${c.description?`<p class="text-sm text-slate-600 mb-3 whitespace-pre-wrap">${c.description}</p>`:''}
<div class="flex justify-end mt-2"><span class="bg-slate-100 text-slate-600 text-xs py-1 px-2 rounded font-medium border">&#9201;&#65039; Total: ${c.hours||'0h 0m'}</span></div>`;
document.getElementById('col-'+c.column).appendChild(el);
});
}
function allowDrop(e){e.preventDefault();}
function drop(e,col){
e.preventDefault();
const id=e.dataTransfer.getData("id");
const card=cards.find(x=>x.id===id);
if(card && card.column!==col){card.column=col;saveData();render();}
}
document.getElementById('cardForm').onsubmit=(e)=>{
e.preventDefault();
const id=document.getElementById('cardId').value;
const t=document.getElementById('title').value; const p=document.getElementById('project').value;
const dt=document.getElementById('date').value; const st=document.getElementById('startTime').value;
const et=document.getElementById('endTime').value;
const h=document.getElementById('hours').value; const c=document.getElementById('column').value;
const d=document.getElementById('description').value;
if(id){const card=cards.find(x=>x.id===id); card.title=t;card.project=p;card.date=dt;card.startTime=st;card.endTime=et;card.hours=h;card.column=c;card.description=d;}
else{cards.push({id:'c'+Date.now(),title:t,project:p,date:dt,startTime:st,endTime:et,hours:h,column:c,description:d});}
saveData();render();e.target.reset();document.getElementById('cardId').value='';
};
window.editCard=(id)=>{
const c=cards.find(x=>x.id===id);
document.getElementById('cardId').value=c.id; document.getElementById('title').value=c.title;
document.getElementById('project').value=c.project; document.getElementById('date').value=c.date||'';
document.getElementById('startTime').value=c.startTime||''; document.getElementById('endTime').value=c.endTime||'';
document.getElementById('hours').value=c.hours||'';
document.getElementById('column').value=c.column; document.getElementById('description').value=c.description;
window.scrollTo({top:0,behavior:'smooth'});
};
window.delCard=(id)=>{if(confirm('Excluir card permanentemente?')){cards=cards.filter(x=>x.id!==id);saveData();render();}};
loadData();
</script>
</body>
</html>
'@

$listener=New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
try{
$listener.Start()
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Servidor rodando na porta $port" -ForegroundColor Green
Write-Host " Pressione CTRL+C para encerrar." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan
Start-Process $url
while($listener.IsListening){
$ctx=$listener.GetContext()
$req=$ctx.Request
$res=$ctx.Response
if($req.Url.AbsolutePath -eq '/'){
$buf=[System.Text.Encoding]::UTF8.GetBytes($htmlContent)
$res.ContentType="text/html; charset=utf-8"
$res.ContentLength64=$buf.Length
$res.OutputStream.Write($buf,0,$buf.Length)
$res.Close()
}elseif($req.Url.AbsolutePath -eq '/api/data'){
if($req.HttpMethod -eq 'GET'){
$data="[]"
if(Test-Path $jsonFile){$data=Get-Content -Path $jsonFile -Raw -Encoding UTF8}
$buf=[System.Text.Encoding]::UTF8.GetBytes($data)
$res.ContentType="application/json; charset=utf-8"
$res.ContentLength64=$buf.Length
$res.OutputStream.Write($buf,0,$buf.Length)
$res.Close()
}elseif($req.HttpMethod -eq 'POST'){
$rd=New-Object System.IO.StreamReader($req.InputStream,[System.Text.Encoding]::UTF8)
$body=$rd.ReadToEnd()
$rd.Close()
$body | Out-File -FilePath $jsonFile -Encoding UTF8 -Force
$res.StatusCode=200
$res.Close()
}
}else{
$res.StatusCode=404
$res.Close()
}
}
}catch{
Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}finally{
if($listener.IsListening){$listener.Stop()}
$listener.Close()
Write-Host "Servidor encerrado com sucesso." -ForegroundColor Green
}