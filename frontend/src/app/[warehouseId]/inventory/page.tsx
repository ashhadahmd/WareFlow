'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/api';
import {
  Search,
  Plus,
  Edit2,
  Trash2,
  Filter,
  Loader2,
  X,
  AlertTriangle
} from 'lucide-react';
import toast from 'react-hot-toast';

// Local helper function for conditional class application
const cn = (...classes: (string | boolean | undefined | null)[]) => {
  return classes.filter(Boolean).join(' ');
};

export default function InventoryPage() {
  const [products, setProducts] = useState<any[]>([]);
  const [suppliers, setSuppliers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [productToDelete, setProductToDelete] = useState<number | null>(null);
  const [editingProduct, setEditingProduct] = useState<any>(null);
  const [formData, setFormData] = useState({
    sku: '', name: '', category: '', quantity: 0, min_stock: 0, price: 0, location: '', supplier_id: ''
  });

  const generateSKU = () => `WH-${Math.random().toString(36).substring(2, 7).toUpperCase()}`;

  useEffect(() => {
    fetchData();
  }, [search, categoryFilter]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const params: any = {};
      if (search) params.search = search;
      if (categoryFilter) params.category = categoryFilter;

      const [prods, sups] = await Promise.all([
        api.get('/inventory/', params),
        api.get('/suppliers/')
      ]);
      setProducts(prods as any[]);
      setSuppliers(sups as any[]);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const categories = Array.from(new Set(products.map(p => p.category).filter(Boolean)));

  const handleOpenModal = (product: any = null) => {
    if (product) {
      setEditingProduct(product);
      setFormData({
        sku: product.sku, name: product.name, category: product.category || '',
        quantity: product.quantity, min_stock: product.min_stock,
        price: product.price, location: product.location || '',
        supplier_id: product.supplier_id?.toString() || ''
      });
    } else {
      setEditingProduct(null);
      setFormData({
        sku: generateSKU(), name: '', category: '', quantity: 0,
        min_stock: 0, price: 0, location: '', supplier_id: ''
      });
    }
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.supplier_id) {
      toast.error("Please select a valid Supplier.");
      return;
    }
    try {
      const payload = { ...formData, supplier_id: parseInt(formData.supplier_id) };
      if (editingProduct) {
        await api.put(`/inventory/${editingProduct.id}`, payload);
        toast.success("Product updated successfully!");
      } else {
        await api.post('/inventory/', payload);
        toast.success("Product added successfully!");
      }
      setIsModalOpen(false);
      fetchData();
    } catch (error: any) {
      toast.error("Error saving product: " + error.message);
    }
  };

  const confirmDelete = (id: number) => {
    setProductToDelete(id);
    setIsDeleteModalOpen(true);
  };

  const handleDelete = async () => {
    if (!productToDelete) return;
    try {
      await api.delete(`/inventory/${productToDelete}`);
      toast.success("Product deleted successfully!");
      setIsDeleteModalOpen(false);
      fetchData();
    } catch (error: any) {
      toast.error("Error deleting product: " + error.message);
    }
  };

  return (
    <div className="space-y-6 px-2 sm:px-0 pb-10">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-foreground">Inventory</h1>
          <p className="text-zinc-500 dark:text-zinc-400 mt-1 text-sm">Manage your warehouse products and stock levels.</p>
        </div>
        <button onClick={() => handleOpenModal()} className="btn-primary flex items-center justify-center gap-2 w-full sm:w-auto py-3 px-6 rounded-xl font-bold text-xs uppercase tracking-widest transition-all hover:scale-[1.02] active:scale-95">
          <Plus size={18} /> Add Product
        </button>
      </div>

      {/* Filter Section */}
      <div className="glass-panel p-4 flex flex-col sm:flex-row gap-4 border border-gray-100 dark:border-white/5">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            placeholder="Search SKU or Name..."
            className="glass-input !pl-10 w-full placeholder:font-medium placeholder:uppercase placeholder:tracking-widest"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <div className="relative w-full sm:w-64">
          <Filter className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <select
            className="glass-input !pl-10 appearance-none bg-white/60 w-full"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
          >
            <option value="">All Categories</option>
            {categories.map(c => <option key={c as string} value={c as string}>{c as string}</option>)}
          </select>
        </div>
      </div>

      {/* Table & Card Section */}
      <div className="glass-panel overflow-hidden border border-gray-100 dark:border-white/5">
        <div className="overflow-x-auto">
          {loading ? (
            <div className="p-12 flex justify-center"><Loader2 className="animate-spin text-primary" size={32} /></div>
          ) : products.length === 0 ? (
            <div className="col-span-full text-center py-12 text-gray-500">No products found.</div>
          ) : (
            <>
              {/* Desktop Table */}
              <div className="hidden md:block overflow-x-auto">
                <table className="w-full min-w-[800px] glass-table">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left px-4 py-3">SKU</th>
                      <th className="text-left px-4 py-3">Product Name</th>
                      <th className="text-left px-4 py-3">Category</th>
                      <th className="text-left px-4 py-3">Stock</th>
                      <th className="text-left px-4 py-3">Price</th>
                      <th className="text-left px-4 py-3">Location</th>
                      <th className="text-left px-4 py-3">Status</th>
                      <th className="text-right px-4 py-3">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {products.map((product) => {
                      const isLow = product.quantity < product.min_stock;
                      return (
                        <tr key={product.id} className="border-b border-gray-50">
                          <td className="px-4 py-3 font-mono text-sm text-foreground">{product.sku}</td>
                          <td className="px-4 py-3 font-medium text-foreground">{product.name}</td>
                          <td className="px-4 py-3"><span className="bg-gray-100 text-gray-700 px-2 py-1 rounded text-[10px] font-bold uppercase">{product.category || 'General'}</span></td>
                          <td className="px-4 py-3">
                            <div className="flex items-center gap-2">
                              <span className={isLow ? 'text-red-600 font-bold' : 'text-foreground'}>{product.quantity}</span>
                              <span className="text-xs text-gray-400">/ {product.min_stock}</span>
                            </div>
                          </td>
                          <td className="px-4 py-3">${product.price.toFixed(2)}</td>
                          <td className="px-4 py-3 text-sm text-foreground">{product.location || '-'}</td>
                          <td className="px-4 py-3">
                            {/* ✅ Desktop Badge Fix */}
                            <span
                              className={cn(
                                'px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest',
                                isLow
                                  ? 'bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-400'
                                  : 'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-400'
                              )}
                            >
                              {isLow ? 'Low Stock' : 'In Stock'}
                            </span>
                          </td>
                          <td className="px-4 py-3">
                            <div className="flex justify-end gap-2">
                              <button onClick={() => handleOpenModal(product)} className="p-1.5 text-gray-400 hover:text-primary hover:bg-black/5 rounded transition-colors">
                                <Edit2 size={16} />
                              </button>
                              <button onClick={() => confirmDelete(product.id)} className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors">
                                <Trash2 size={16} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>

              {/* Mobile Cards */}
              <div className="md:hidden space-y-4 p-3">
                {products.map((product) => {
                  const isLow = product.quantity < product.min_stock;
                  return (
                    <div key={product.id} className="glass-panel p-4 rounded-xl space-y-2">
                      <div className="flex justify-between items-start">
                        <h3 className="font-semibold text-foreground">{product.name}</h3>
                        {/* ✅ Mobile Badge Fix */}
                        <span
                          className={cn(
                            'px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest',
                            isLow
                              ? 'bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-400'
                              : 'bg-green-100 text-green-700 dark:bg-green-500/20 dark:text-green-400'
                          )}
                        >
                          {isLow ? 'Low' : 'In Stock'}
                        </span>
                      </div>
                      <p className="text-xs text-foreground font-mono">{product.sku}</p>
                      <div className="text-sm text-foreground">
                        <p>Category: {product.category || 'General'}</p>
                        <p>Stock: {product.quantity} / {product.min_stock}</p>
                        <p>Price: ${product.price.toFixed(2)}</p>
                        <p>Location: {product.location || '-'}</p>
                      </div>
                      <div className="flex justify-end gap-3 pt-2">
                        <button onClick={() => handleOpenModal(product)} className="p-1.5 text-foreground hover:text-primary hover:bg-black/5 rounded">
                          <Edit2 size={16} />
                        </button>
                        <button onClick={() => confirmDelete(product.id)} className="p-1.5 text-red-400 hover:text-red-500 hover:bg-red-50 rounded">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Modal - Ye as it is hai */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[100] flex items-center justify-center p-4">
          <div className="glass-modal w-full max-w-2xl max-h-[90vh] flex flex-col">
            <div className="flex justify-between items-center p-6 border-b border-gray-100">
              <h2 className="text-xl font-bold text-gray-900">{editingProduct ? 'Edit Product' : 'Add New Product'}</h2>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-900">
                <X size={24} />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 overflow-y-auto space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">SKU (Auto-Generated)</label>
                  <input readOnly type="text" className="glass-input bg-gray-50 cursor-not-allowed" value={formData.sku} />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Product Name *</label>
                  <input required type="text" className="glass-input w-full" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Category</label>
                  <input type="text" className="glass-input w-full" value={formData.category} onChange={e => setFormData({ ...formData, category: e.target.value })} />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Location</label>
                  <input type="text" className="glass-input w-full" value={formData.location} onChange={e => setFormData({ ...formData, location: e.target.value })} />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Price ($)</label>
                  <input required type="number" step="0.01" min="0" className="glass-input w-full" value={formData.price} onChange={e => setFormData({ ...formData, price: parseFloat(e.target.value) })} />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Supplier *</label>
                  <select required className="glass-input w-full bg-white" value={formData.supplier_id} onChange={e => setFormData({ ...formData, supplier_id: e.target.value })}>
                    <option value="">Select Supplier</option>
                    {suppliers.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Current Quantity</label>
                  <input required type="number" min="0" className="glass-input w-full" value={formData.quantity} onChange={e => setFormData({ ...formData, quantity: parseInt(e.target.value) })} />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase tracking-widest text-gray-500 mb-1">Min. Stock Alert</label>
                  <input required type="number" min="0" className="glass-input w-full" value={formData.min_stock} onChange={e => setFormData({ ...formData, min_stock: parseInt(e.target.value) })} />
                </div>
              </div>

              <div className="flex flex-col sm:flex-row justify-end gap-3 mt-8 pt-4 border-t border-gray-100">
                <button type="button" onClick={() => setIsModalOpen(false)} className="btn-secondary w-full sm:w-auto">Cancel</button>
                <button type="submit" className="btn-primary w-full sm:w-auto">{editingProduct ? 'Save Changes' : 'Create Product'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {isDeleteModalOpen && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[110] flex items-center justify-center p-4">
          <div className="bg-background border border-gray-100 dark:border-white/5 w-full max-w-sm rounded-[2rem] p-8 text-center animate-in fade-in zoom-in-95 duration-200 shadow-2xl">
            <div className="w-16 h-16 bg-rose-500/10 text-rose-500 rounded-full flex items-center justify-center mx-auto mb-6">
              <AlertTriangle size={32} />
            </div>
            <h3 className="text-xl font-black uppercase tracking-tighter text-zinc-900 dark:text-zinc-50 mb-2">Are you sure?</h3>
            <p className="text-zinc-500 text-sm mb-8">This action will permanently delete the product from your inventory. This cannot be undone.</p>
            <div className="flex gap-3">
              <button onClick={() => setIsDeleteModalOpen(false)} className="flex-1 py-3 bg-zinc-100 dark:bg-zinc-800 rounded-xl font-bold text-xs uppercase tracking-widest text-zinc-900 dark:text-zinc-50 text-center hover:bg-zinc-200 dark:hover:bg-zinc-700 transition-colors">No, Keep</button>
              <button onClick={handleDelete} className="flex-1 py-3 bg-rose-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest text-center hover:bg-rose-700 transition-colors">Yes, Delete</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}