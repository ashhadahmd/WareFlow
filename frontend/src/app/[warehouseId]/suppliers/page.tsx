'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/api';
import { Plus, Edit2, Trash2, Mail, Phone, MapPin, Star, Building, X, Loader2, AlertTriangle } from 'lucide-react';
import toast from 'react-hot-toast';

// Helper function for conditional classes
const cn = (...classes: any[]) => classes.filter(Boolean).join(' ');

export default function SuppliersPage() {
  const [suppliers, setSuppliers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Modal States
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [supplierToDelete, setSupplierToDelete] = useState<number | null>(null);
  const [editingSupplier, setEditingSupplier] = useState<any>(null);

  const [formData, setFormData] = useState({
    name: '', contact_name: '', email: '', phone: '', address: '', status: 'active', rating: 0
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const data = await api.get('/suppliers/');
      setSuppliers(data as any[]);
    } catch (error) {
      toast.error("Failed to load suppliers");
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (supplier: any = null) => {
    if (supplier) {
      setEditingSupplier(supplier);
      setFormData({
        name: supplier.name, contact_name: supplier.contact_name || '', email: supplier.email || '', 
        phone: supplier.phone || '', address: supplier.address || '', status: supplier.status, rating: supplier.rating || 0
      });
    } else {
      setEditingSupplier(null);
      setFormData({ name: '', contact_name: '', email: '', phone: '', address: '', status: 'active', rating: 3.0 });
    }
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const loadingToast = toast.loading(editingSupplier ? "Updating supplier..." : "Adding supplier...");
    try {
      if (editingSupplier) {
        await api.put(`/suppliers/${editingSupplier.id}`, formData);
        toast.success("Supplier updated!", { id: loadingToast });
      } else {
        await api.post('/suppliers/', formData);
        toast.success("New supplier added!", { id: loadingToast });
      }
      setIsModalOpen(false);
      fetchData();
    } catch (error: any) {
      toast.error(error.message || "Operation failed", { id: loadingToast });
    }
  };

  const confirmDelete = (id: number) => {
    setSupplierToDelete(id);
    setIsDeleteModalOpen(true);
  };

  const handleDelete = async () => {
    if (!supplierToDelete) return;
    const loadingToast = toast.loading("Deleting...");
    try {
      await api.delete(`/suppliers/${supplierToDelete}`);
      toast.success("Supplier removed", { id: loadingToast });
      setIsDeleteModalOpen(false);
      fetchData();
    } catch (error: any) {
      toast.error("Error deleting supplier", { id: loadingToast });
    }
  };

  return (
    <div className="space-y-6 pb-10">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 px-1">
        <div>
          <h1 className="text-3xl font-black tracking-tighter text-white-900 dark:text-black-50 uppercase">
            Suppliers
          </h1>
          <p className="text-zinc-500 dark:text-zinc-400 mt-1 text-sm font-medium">
            Manage vendor relationships and logistics partners.
          </p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center justify-center gap-2 py-3 px-6 rounded-xl font-bold text-xs uppercase tracking-widest transition-all hover:scale-[1.02] active:scale-95 w-full sm:w-auto">
          <Plus size={18} /> Add Supplier
        </button>
      </div>

      {loading ? (
        <div className="flex justify-center p-20"><Loader2 className="animate-spin text-primary" size={40} /></div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {suppliers.length === 0 ? (
            <div className="col-span-full text-center py-20 text-zinc-500 glass-panel uppercase font-black tracking-widest text-xs">No records found.</div>
          ) : suppliers.map((supplier) => (
            <div key={supplier.id} className="glass-panel p-6 flex flex-col hover:shadow-2xl transition-all group border border-border/40 relative overflow-hidden bg-card/50">
              
              <div className="flex justify-between items-start mb-6 gap-2">
                <div className="flex items-center gap-4 min-w-0">
                  <div className="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary shrink-0 border border-primary/20">
                    <Building size={24} />
                  </div>
                  <div className="min-w-0">
                    <h3 className="font-bold text-lg text-white-900 dark:text-black-100 leading-tight truncate">
                      {supplier.name}
                    </h3>
                    <span className={cn(
                      "inline-block px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-widest mt-1.5 border",
                      supplier.status === 'active' ? "bg-emerald-500/10 text-emerald-600 border-emerald-500/20" : "bg-rose-500/10 text-rose-600 border-rose-500/20"
                    )}>
                      {supplier.status}
                    </span>
                  </div>
                </div>
                
                {/* Fixed Action Buttons */}
                <div className="flex gap-1 shrink-0">
                  <button onClick={() => handleOpenModal(supplier)} className="p-2 text-zinc-400 hover:text-primary hover:bg-primary/10 rounded-xl transition-colors">
                    <Edit2 size={16} />
                  </button>
                  <button onClick={() => confirmDelete(supplier.id)} className="p-2 text-zinc-400 hover:text-rose-500 hover:bg-rose-500/10 rounded-xl transition-colors">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>

              <div className="space-y-3.5 flex-1 text-sm text-white-600 dark:text-black-400">
                {supplier.contact_name && (
                   <p className="font-black text-white-800 dark:text-black-200 text-[10px] uppercase tracking-wider">{supplier.contact_name}</p>
                )}
                <div className="space-y-2">
                  {supplier.email && (
                    <div className="flex items-center gap-3 overflow-hidden">
                      <Mail size={14} className="text-zinc-400 shrink-0" />
                      <a href={`mailto:${supplier.email}`} className="hover:text-primary transition-colors truncate font-medium">{supplier.email}</a>
                    </div>
                  )}
                  {supplier.phone && (
                    <div className="flex items-center gap-3">
                      <Phone size={14} className="text-zinc-400 shrink-0" />
                      <span className="font-bold tracking-tighter">{supplier.phone}</span>
                    </div>
                  )}
                  {supplier.address && (
                    <div className="flex items-start gap-3 pt-1">
                      <MapPin size={14} className="text-zinc-400 shrink-0 mt-1" />
                      <span className="line-clamp-2 leading-relaxed text-xs">{supplier.address}</span>
                    </div>
                  )}
                </div>
              </div>

              <div className="mt-8 pt-4 border-t border-border/50 flex items-center justify-between">
                <div className="flex items-center gap-1.5 text-amber-500 bg-amber-500/5 px-2.5 py-1 rounded-lg border border-amber-500/10">
                  <Star size={14} className="fill-current" />
                  <span className="text-xs font-black">{supplier.rating?.toFixed(1) || '0.0'}</span>
                </div>
                <span className="text-[10px] font-black text-black-400 uppercase tracking-widest opacity-50">UID: {supplier.id}</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Main Form Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-md z-[100] flex items-center justify-center p-4 overflow-y-auto">
          <div className="glass-modal w-full max-w-lg my-auto animate-in zoom-in-95 duration-300 shadow-2xl">
            <div className="flex justify-between items-center p-6 border-b border-border bg-background/50 backdrop-blur-md rounded-t-2xl">
              <h2 className="text-xl font-black uppercase tracking-tighter text-zinc-900 dark:text-zinc-50">
                {editingSupplier ? 'Edit Supplier' : 'New Supplier'}
              </h2>
              <button onClick={() => setIsModalOpen(false)} className="p-2 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-full transition-colors">
                <X size={24} className="text-zinc-400" />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-5">
              <div className="space-y-1.5">
                <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Company Name *</label>
                <input required type="text" className="glass-input w-full" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                <div className="space-y-1.5">
                  <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Email</label>
                  <input type="email" className="glass-input w-full" value={formData.email} onChange={e => setFormData({...formData, email: e.target.value})} />
                </div>
                <div className="space-y-1.5">
                  <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Phone</label>
                  <input type="text" className="glass-input w-full" value={formData.phone} onChange={e => setFormData({...formData, phone: e.target.value})} />
                </div>
              </div>
              <div className="space-y-1.5">
                <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Full Address</label>
                <textarea className="glass-input w-full resize-none h-20" value={formData.address} onChange={e => setFormData({...formData, address: e.target.value})}></textarea>
              </div>
              <div className="flex flex-col sm:flex-row justify-end gap-3 mt-8 pt-6 border-t border-border">
                <button type="button" onClick={() => setIsModalOpen(false)} className="btn-secondary w-full sm:w-auto font-black py-3 px-6 uppercase tracking-widest text-[10px]">Cancel</button>
                <button type="submit" className="btn-primary w-full sm:w-auto font-black py-3 px-8 uppercase tracking-widest text-[10px]">
                  {editingSupplier ? 'Save Changes' : 'Add Supplier'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal (Premium Alternative to confirm()) */}
      {isDeleteModalOpen && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[110] flex items-center justify-center p-4">
          <div className="bg-background border border-border w-full max-w-sm rounded-[2rem] p-8 text-center animate-in fade-in zoom-in-95 duration-200 shadow-2xl">
            <div className="w-16 h-16 bg-rose-500/10 text-rose-500 rounded-full flex items-center justify-center mx-auto mb-6">
              <AlertTriangle size={32} />
            </div>
            <h3 className="text-xl font-black uppercase tracking-tighter text-zinc-900 dark:text-zinc-50 mb-2">Are you sure?</h3>
            <p className="text-zinc-500 text-sm mb-8">This action will permanently delete the supplier from your database. This cannot be undone.</p>
            <div className="flex gap-3">
              <button onClick={() => setIsDeleteModalOpen(false)} className="flex-1 py-3 bg-zinc-100 dark:bg-zinc-800 rounded-xl font-bold text-xs uppercase tracking-widest">No, Keep</button>
              <button onClick={handleDelete} className="flex-1 py-3 bg-rose-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-rose-700 transition-colors">Yes, Delete</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}