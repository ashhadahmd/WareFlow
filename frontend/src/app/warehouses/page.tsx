'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Cookies from 'js-cookie';
import { Building2, Plus, LogOut, ArrowRight, Loader2 } from 'lucide-react';
import { api } from '@/lib/api';

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
      const newWh = await api.post('/warehouses/', { name: newWarehouseName });
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
    return <div className="min-h-screen flex items-center justify-center bg-background"><Loader2 className="animate-spin text-muted-foreground" size={32} /></div>;
  }

  return (
    // Mobile par 'p-4' aur desktop par 'p-8'
    <div className="min-h-screen px-4 py-8 sm:p-8 max-w-4xl mx-auto bg-background">
      
      {/* Header ko mobile par stack (column) kiya hai */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8 sm:mb-12">
        <h1 className="text-2xl sm:text-3xl font-black tracking-tighter flex items-center gap-3 uppercase">
          <Building2 className="text-primary w-6 h-6 sm:w-8 sm:h-8" />
          Warehouses
        </h1>
        <button 
          onClick={handleLogout} 
          className="text-muted-foreground hover:text-foreground flex items-center gap-2 text-xs sm:text-sm font-bold uppercase tracking-widest transition-colors"
        >
          <LogOut size={16} /> Logout
        </button>
      </div>

      {/* Grid items spacing optimize ki gayi hai */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
        {warehouses.map((wh) => (
          <button 
            key={wh.id}
            onClick={() => selectWarehouse(wh.id)}
            // 'h-36' for mobile and 'sm:h-40' for desktop
            className="glass-panel p-5 sm:p-6 text-left hover:-translate-y-1 transition-all group border-transparent hover:border-border cursor-pointer flex flex-col justify-between h-36 sm:h-40 shadow-sm hover:shadow-xl"
          >
            <div>
              <h3 className="font-bold text-base sm:text-lg text-foreground group-hover:text-primary transition-colors line-clamp-1">{wh.name}</h3>
              <p className="text-[10px] sm:text-xs font-bold uppercase tracking-widest text-muted-foreground mt-1">
                Joined {new Date(wh.created_at).toLocaleDateString()}
              </p>
            </div>
            <div className="flex justify-end opacity-100 sm:opacity-0 group-hover:opacity-100 transition-opacity">
              <div className="bg-primary/10 p-2 rounded-full text-primary">
                <ArrowRight size={18} />
              </div>
            </div>
          </button>
        ))}

        {!showCreate ? (
          <button 
            onClick={() => setShowCreate(true)}
            className="glass-panel p-6 border-dashed border-2 border-border flex flex-col items-center justify-center text-muted-foreground hover:text-foreground hover:bg-primary/5 transition-all h-36 sm:h-40 cursor-pointer group"
          >
            <div className="bg-muted p-3 rounded-full mb-3 group-hover:bg-primary/20 group-hover:text-primary transition-colors">
              <Plus size={24} />
            </div>
            <span className="font-bold text-xs sm:text-sm uppercase tracking-widest">Create New</span>
          </button>
        ) : (
          <div className="glass-panel p-5 sm:p-6 h-36 sm:h-40 flex flex-col justify-center border-primary/20">
             <form onSubmit={handleCreate}>
               <input 
                  autoFocus
                  type="text" 
                  placeholder="Warehouse Name" 
                  className="glass-input mb-3 sm:mb-4 text-sm w-full" 
                  value={newWarehouseName}
                  onChange={e => setNewWarehouseName(e.target.value)}
                />
               <div className="flex gap-2">
                 <button type="submit" className="btn-primary text-xs font-bold py-2 flex-1">Create</button>
                 <button type="button" onClick={() => setShowCreate(false)} className="btn-secondary text-xs font-bold py-2 px-3">Cancel</button>
               </div>
             </form>
          </div>
        )}
      </div>
    </div>
  );
}