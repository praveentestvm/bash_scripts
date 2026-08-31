document.addEventListener('DOMContentLoaded',()=>{
 const type=document.getElementById('transaction-type'),cat=document.getElementById('transaction-category'),form=document.getElementById('transaction-form');
 if(!type||!cat||!form)return;
 type.addEventListener('change',async()=>{
   const endpoint=form.dataset.categoryUrl;
   try{
     const r=await fetch(endpoint+'?type='+encodeURIComponent(type.value),{headers:{'Accept':'application/json'}});
     if(!r.ok)throw new Error('Category request failed');
     const items=await r.json();
     cat.innerHTML='';
     items.forEach(x=>{const o=document.createElement('option');o.value=x.id;o.textContent=x.name;cat.appendChild(o);});
   }catch(e){ console.error(e); }
 });
});
