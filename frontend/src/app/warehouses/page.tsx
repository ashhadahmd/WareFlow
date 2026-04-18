'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Cookies from 'js-cookie';
import { 
  Building2, 
  Plus, 
  LogOut, 
  ArrowRight, 
  Loader2, 
  Globe, 
  LayoutDashboard,
  X,
  Zap
} from 'lucide-react';
import { api } from '@/lib/api';
import { ThemeToggle } from '@/components/ThemeToggle';

// Local helper to ensure cursor and theme consistency
const cn = (...classes: any[]) => classes.filter(Boolean).join(' ');

export default function WarehousesPage() {
  const router = useRouter();
  const [warehouses, setWarehouses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showCreate, setShowCreate] = useState(false);
  const [newWarehouseName, setNewWarehouseName] = useState('');

  useEffect(() => {
    fetchWarehouses();
  }, []);

  const fetchWarehouses = async () => {
    try {
      const data = await api.get('/warehouses/');
      setWarehouses(data as any[]);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const selectWarehouse = (id: string) => {
    Cookies.set('warehouseId', id);
    router.push(`/${id}`);
  };

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newWarehouseName) return;
    
    try {
      setLoading(true);
      await api.post('/warehouses/', { name: newWarehouseName });
      await fetchWarehouses();
      setShowCreate(false);
      setNewWarehouseName('');
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    Cookies.remove('token');
    Cookies.remove('warehouseId');
    router.push('/login');
  };

  if (loading && warehouses.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <Loader2 className="animate-spin text-primary" size={40} />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background relative overflow-hidden selection:bg-primary/30">
      
      {/* --- PREMIUM BACKGROUND ELEMENTS --- */}
      <div className="absolute inset-0 pointer-events-none opacity-30">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary/20 blur-[120px] rounded-full animate-pulse" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-blue-500/10 blur-[120px] rounded-full animate-pulse" style={{ animationDelay: '2s' }} />
        <svg viewBox="0 0 1440 320" className="absolute top-1/4 left-0 w-full opacity-20">
          <path fill="none" stroke="currentColor" strokeWidth="1" d="M0,160 C320,300 420,0 720,160 C1020,320 1120,20 1440,160" className="text-primary" />
        </svg>
      </div>

      <div className="relative z-10 max-w-6xl mx-auto px-4 sm:px-6 py-10 md:py-20">
        
        {/* --- TOP NAVIGATION BAR --- */}
        <nav className="flex justify-between items-center mb-12 sm:mb-24 animate-in fade-in slide-in-from-top-4 duration-700">
          <div className="flex items-center gap-2 sm:gap-4 group cursor-pointer shrink-0" >
            <div className="transition-transform group-hover:scale-110 duration-300">
              <img 
                src="/logo.svg" 
                alt="WareFlow Logo" 
                className="w-8 h-8 sm:w-10 sm:h-10 object-contain transition-all" 
              />
            </div>
            <span className="text-lg sm:text-2xl font-black tracking-tighter uppercase text-foreground">WareFlow</span>
          </div>
          
          <div className="flex items-center gap-2 sm:gap-4">
            <ThemeToggle />
            <button 
              onClick={handleLogout} 
              className="group flex items-center gap-2 px-3 sm:px-4 py-2 rounded-full border border-border bg-card/50 hover:bg-destructive/10 hover:text-destructive hover:border-destructive/20 transition-all cursor-pointer text-[10px] sm:text-xs font-black uppercase tracking-widest shrink-0"
            >
              <LogOut size={14} className="group-hover:-translate-x-1 transition-transform" />
              {/* MOBILE FIX: Hide text on mobile to prevent cut-off */}
              <span className="hidden sm:inline">Sign Out</span>
            </button>
          </div>
        </nav>

        {/* --- HERO SECTION --- */}
        <header className="mb-12 text-center sm:text-left animate-in fade-in slide-in-from-bottom-4 duration-700 delay-100">
          <h1 className="text-4xl sm:text-6xl font-black tracking-tighter uppercase text-foreground leading-[0.9] mb-4">
            Select <span className="text-muted-foreground">Workspace</span>
          </h1>
          <p className="text-muted-foreground max-w-md text-sm sm:text-base font-medium px-4 sm:px-0">
            Welcome back. Choose a facility to manage inventory, track shipments, and oversee team operations.
          </p>
        </header>

        {/* --- WAREHOUSE GRID --- */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 animate-in fade-in slide-in-from-bottom-8 duration-1000 delay-200">
          {warehouses.map((wh, idx) => (
            <div 
              key={wh.id}
              onClick={() => selectWarehouse(wh.id)}
              className="glass-panel group relative p-6 sm:p-8 cursor-pointer overflow-hidden border-border/50 hover:border-primary/50 hover:shadow-[0_0_40px_rgba(168,85,247,0.15)] transition-all duration-500 min-h-[160px] sm:min-h-[180px] flex flex-col justify-between"
            >
              <span className="absolute top-4 right-6 text-5xl sm:text-6xl font-black text-foreground/[0.6] group-hover:text-primary transition-colors duration-500">
                0{idx + 1}
              </span>

              <div className="relative z-10">
                <div className="w-10 h-10 sm:w-12 sm:h-12 bg-accent rounded-lg flex items-center justify-center mb-4 group-hover:bg-primary/10 group-hover:text-primary transition-colors">
                  <Building2 size={20} className="sm:w-6 sm:h-6" />
                </div>
                <h3 className="font-black text-lg sm:text-xl text-foreground uppercase tracking-tight group-hover:text-primary transition-colors truncate pr-10">
                  {wh.name}
                </h3>
                {/* DATE FIX: Back to Joined DD/MM/YYYY format */}
                <p className="text-[9px] sm:text-[10px] font-black uppercase tracking-[0.2em] text-muted-foreground mt-2">
                  Joined {new Date(wh.created_at).toLocaleDateString('en-GB')}
                </p>
              </div>

              <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-primary opacity-100 sm:opacity-0 sm:translate-x-[-10px] sm:group-hover:opacity-100 sm:group-hover:translate-x-0 transition-all duration-300 mt-4">
                <span>Enter Workspace</span>
                <ArrowRight size={14} />
              </div>
            </div>
          ))}

          {/* CREATE BUTTON CARD */}
          <button 
            onClick={() => setShowCreate(true)}
            className="glass-panel relative p-6 sm:p-8 border-dashed border-2 border-border flex flex-col items-center justify-center gap-4 text-muted-foreground hover:text-primary hover:border-primary/50 hover:bg-primary/5 transition-all duration-500 min-h-[160px] sm:min-h-[180px] cursor-pointer group"
          >
            <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-full border-2 border-dashed border-border group-hover:border-primary group-hover:rotate-90 flex items-center justify-center transition-all duration-500">
              <Plus size={24} />
            </div>
            <span className="font-black text-[10px] sm:text-xs uppercase tracking-[0.3em]">Deploy New Facility</span>
          </button>
        </div>
      </div>

      {/* --- CREATE MODAL --- */}
      {showCreate && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 overflow-y-auto animate-in fade-in duration-300">
          <div className="fixed inset-0 bg-background/80 backdrop-blur-md cursor-pointer" onClick={() => setShowCreate(false)} />
          
          <div className="glass-modal w-full max-w-lg my-auto animate-in zoom-in-95 duration-300 shadow-2xl relative border border-primary/20 overflow-hidden">
            <div className="h-1.5 w-full bg-gradient-to-r from-primary via-blue-500 to-primary animate-gradient-x" />
            
            <div className="p-6 sm:p-12">
              <button 
                onClick={() => setShowCreate(false)} 
                className="absolute top-4 right-4 sm:top-6 sm:right-6 p-2 hover:bg-accent rounded-full transition-colors cursor-pointer"
              >
                <X size={20} />
              </button>

              <div className="w-14 h-14 sm:w-16 sm:h-16 bg-primary/10 text-primary rounded-2xl flex items-center justify-center mb-6 sm:mb-8 mx-auto sm:mx-0">
                <Globe size={28} className="animate-pulse" />
              </div>

              <div className="text-center sm:text-left mb-8 sm:mb-10">
                <h2 className="text-2xl sm:text-3xl font-black uppercase tracking-tighter text-foreground mb-3">Create Workspace</h2>
                <p className="text-muted-foreground text-xs sm:text-sm font-medium leading-relaxed">
                  Initializing a new facility will allow you to track dedicated stock levels and oversee team operations.
                </p>
              </div>

              <form onSubmit={handleCreate} className="space-y-6 sm:space-y-8">
                <div className="space-y-3">
                  <label className="text-[9px] sm:text-[10px] font-black uppercase tracking-[0.3em] text-muted-foreground ml-1">Facility Identity *</label>
                  <input 
                    autoFocus
                    required
                    type="text" 
                    placeholder="E.G. NORTHERN HUB" 
                    className="glass-input w-full py-4 sm:py-5 px-4 sm:px-6 text-base sm:text-lg font-bold placeholder:font-black placeholder:text-[9px] placeholder:tracking-[0.2em] border-2 focus:border-primary" 
                    value={newWarehouseName}
                    onChange={e => setNewWarehouseName(e.target.value)}
                  />
                </div>

                <div className="flex flex-col sm:flex-row gap-3 sm:gap-4 pt-2">
                  <button 
                    type="button" 
                    onClick={() => setShowCreate(false)} 
                    className="btn-secondary flex-1 py-3 sm:py-4 text-[10px] font-black uppercase tracking-widest cursor-pointer order-2 sm:order-1"
                  >
                    Cancel
                  </button>
                  <button 
                    type="submit" 
                    disabled={loading} 
                    className="btn-primary flex-1 py-3 sm:py-4 text-[10px] font-black uppercase tracking-widest disabled:opacity-50 flex items-center justify-center gap-2 cursor-pointer shadow-xl shadow-primary/20 order-1 sm:order-2"
                  >
                    {loading ? <Loader2 className="animate-spin" size={16} /> : <LayoutDashboard size={16} />}
                    {loading ? 'Deploying...' : 'Deploy Workspace'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      <style jsx global>{`
        @keyframes gradient-x {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }
        .animate-gradient-x {
          background-size: 200% 200%;
          animation: gradient-x 3s linear infinite;
        }
      `}</style>
    </div>
  );
}