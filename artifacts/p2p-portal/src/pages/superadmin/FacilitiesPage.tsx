import {useEffect,useState} from 'react';
import {P2P_API_BASE} from '@/lib/p2pApi';

type Claim={_id:string;gymName:string;workEmail:string;representativeName?:string;status:string;ownershipVerifiedAt?:string;paymentStatus?:string;paymentExpiresAt?:string;tenantId?:string;facilityId?:string;provisioningState?:string;provisioningFailure?:string;reason?:string;ownershipEvidence?:string};
async function enterprise(path:string,method='GET',body?:unknown) {
  const token=sessionStorage.getItem('p2p_backend_jwt');
  if(!token)throw new Error('Sign in with your P2P global administrator account below.');
  const response=await fetch(`${P2P_API_BASE}/enterprise${path}`,{method,headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:body===undefined?undefined:JSON.stringify(body)});
  const data=await response.json();
  if(!response.ok||data.success===false)throw new Error(data.message||'Request failed. Check your P2P administrator access and retry.');
  return data.data;
}
export default function FacilitiesPage(){
  const [claims,setClaims]=useState<Claim[]>([]),[error,setError]=useState(''),[loading,setLoading]=useState(false),[busy,setBusy]=useState(false);
  const [email,setEmail]=useState(''),[password,setPassword]=useState('');
  async function load(){setLoading(true);setError('');try{setClaims((await enterprise('/admin/gym-applications')).items);}catch(e){setClaims([]);setError(String(e));}finally{setLoading(false);}}
  useEffect(()=>{void load();},[]);
  async function login(e:React.FormEvent){e.preventDefault();setBusy(true);setError('');try{
    const response=await fetch(`${P2P_API_BASE}/auth/login`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email,password})});
    const data=await response.json();if(!response.ok||data.data?.user?.role!=='admin'||!data.data?.token)throw new Error('A verified P2P global administrator account is required.');
    sessionStorage.setItem('p2p_backend_jwt',data.data.token);setPassword('');await load();
  }catch(e){setError(String(e));}finally{setPassword('');setBusy(false);}}
  return <div className="p-6 max-w-7xl mx-auto space-y-6"><div><p className="text-xs font-bold uppercase tracking-widest text-muted-foreground">Super Admin · Platform</p><h1 className="text-2xl font-bold">Facilities</h1></div>
    <details><summary>P2P administrator authentication</summary><form onSubmit={login} className="space-y-3"><input aria-label="P2P email" type="email" required value={email} onChange={e=>setEmail(e.target.value)}/><input aria-label="P2P password" type="password" autoComplete="current-password" required value={password} onChange={e=>setPassword(e.target.value)}/><button disabled={busy}>Sign in to enterprise review</button></form></details>
    <button onClick={()=>void load()} disabled={loading||busy}>Refresh applications</button>{loading&&<p role="status">Loading applications…</p>}{error&&<p role="alert">{error}</p>}
    {!loading&&!error&&!claims.length&&<p>No gym applications.</p>}
    <div className="grid sm:grid-cols-2 gap-4">{claims.map(claim=><ClaimReview key={claim._id} claim={claim} reload={load}/>)}</div></div>;
}
function ClaimReview({claim:c,reload}:{claim:Claim;reload:()=>Promise<void>}){
  const [owner,setOwner]=useState(''),[evidence,setEvidence]=useState(''),[reason,setReason]=useState(''),[busy,setBusy]=useState(false),[error,setError]=useState('');
  const [brand,setBrand]=useState<Record<string,string>|null>(null);
  async function action(path:string,body:unknown={},method='POST') {setBusy(true);setError('');try{await enterprise(path,method,body);await reload();}catch(e){setError(String(e));}finally{setBusy(false);}}
  const base=`/admin/gym-applications/${c._id}`;
  const eligible=!!c.ownershipVerifiedAt&&c.paymentStatus==='paid'&&!!c.paymentExpiresAt&&new Date(c.paymentExpiresAt)>new Date();
  return <section className="bg-card border border-border rounded-2xl p-5 space-y-3"><h2 className="font-bold">{c.gymName}</h2><p>{c.representativeName} · {c.workEmail}</p><p>Application: {c.status} · Provisioning: {c.provisioningState||'pending'}</p><p>Ownership: {c.ownershipVerifiedAt?'verified':'review required'} · Payment: {c.paymentStatus||'required'} {c.paymentExpiresAt&&`(expires ${c.paymentExpiresAt})`}</p>
    {c.ownershipEvidence&&<p>Evidence: {c.ownershipEvidence}</p>}{c.reason&&<p>Reason: {c.reason}</p>}{c.provisioningFailure&&<p role="alert">{c.provisioningFailure}</p>}{error&&<p role="alert">{error}</p>}
    <p role="status">{busy ? "Saving verified changes…" : ""}</p><p>Tenant: {c.tenantId||'Not provisioned'}<br/>Facility: {c.facilityId||'Not provisioned'}</p>
    {c.status==='pending_review'&&<><input aria-label="Verified owner user ID" placeholder="Verified owner user ID" value={owner} onChange={e=>setOwner(e.target.value)}/><textarea aria-label="Ownership review evidence" placeholder="Ownership review evidence" value={evidence} onChange={e=>setEvidence(e.target.value)}/><button disabled={busy||!owner||!evidence} onClick={()=>void action(base+'/verify-ownership',{ownerUserId:owner,evidence})}>Verify ownership</button><button disabled={busy||!eligible} onClick={()=>void action(base+'/approve')}>{c.provisioningState==='failed'?'Retry provisioning':'Approve and provision'}</button></>}
    {c.status==='approved'&&<button disabled={busy||!eligible} onClick={()=>void action(base+'/approve')}>Reconcile provisioning</button>}
    <input aria-label="Decision reason" placeholder="Reason for rejection or revocation" value={reason} onChange={e=>setReason(e.target.value)}/>
    {c.status==='pending_review'&&<button disabled={busy||!reason.trim()} onClick={()=>void action(base+'/reject',{reason})}>Reject</button>}
    {c.status==='approved'&&<button disabled={busy||!reason.trim()} onClick={()=>void action(base+'/revoke',{reason})}>Revoke access</button>}
    {c.status==='revoked'&&<button disabled={busy||!eligible} onClick={()=>void action(base+'/reactivate')}>Reactivate verified paid gym</button>}
    {c.tenantId&&<button disabled={busy} onClick={async()=>{setBusy(true);try{setBrand(await enterprise(`/tenants/${encodeURIComponent(c.tenantId!)}/branding`));}catch(e){setError(String(e));}finally{setBusy(false);}}}>Review branding</button>}
    {brand&&<form onSubmit={e=>{e.preventDefault();void action(`/tenants/${encodeURIComponent(c.tenantId!)}/branding`,{gymName:brand.gymName,logoUrl:brand.logoUrl,primaryColor:brand.primaryColor,secondaryColor:brand.secondaryColor,accentColor:brand.accentColor},'PUT');}}>{['gymName','logoUrl','primaryColor','secondaryColor','accentColor'].map(key=><label key={key} className="block">{key}<input type={key.includes('Color')?'color':'text'} value={brand[key]||''} onChange={e=>setBrand({...brand,[key]:e.target.value})}/></label>)}<button disabled={busy}>Save branding override</button></form>}
  </section>;
}
