'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/api';
import { Plus, Eye, CheckCircle2, XCircle, Clock, Loader2, X, PlusCircle, Trash2 } from 'lucide-react';
import toast from 'react-hot-toast';

// Local helper to avoid "Module not found: @/lib/utils"
function cn(...classes: (string | boolean | undefined | null)[]) {
  return classes.filter(Boolean).join(' ');
}

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('inbound');
  
  // Add Order Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [suppliers, setSuppliers] = useState<any[]>([]);
  const [products, setProducts] = useState<any[]>([]);
  const [newOrder, setNewOrder] = useState({
    order_type: 'inbound',
    supplier_id: '',
    notes: '',
    items: [{ product_id: '', quantity: 1, price_at_time: 0 }]
  });

  useEffect(() => {
    fetchOrders();
    api.get('/suppliers/').then(res => setSuppliers(res as any[]));
    api.get('/inventory/').then(res => setProducts(res as any[]));
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const data = await api.get('/orders/');
      setOrders(data as any[]);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (id: number, status: string) => {
    try {
      if (status === 'completed' && !confirm('Completing an order will irreversibly update inventory quantities. Are you sure?')) {
         return;
      }
      await api.patch(`/orders/${id}/status`, { status });
      fetchOrders();
    } catch (error: any) {
      toast.error("Error updating order: " + error.message);
    }
  };

  const handleCreateSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const payload = {
         ...newOrder,
         supplier_id: newOrder.supplier_id ? parseInt(newOrder.supplier_id) : null,
         items: newOrder.items.filter(i => i.product_id).map(i => ({
             product_id: parseInt(i.product_id),
             quantity: i.quantity,
             price_at_time: i.price_at_time
         }))
      };
      
      if (payload.items.length === 0) {
          toast.error("Must add at least one item");
          return;
      }

      await api.post('/orders/', payload);
      setIsModalOpen(false);
      setNewOrder({ order_type: activeTab, supplier_id: '', notes: '', items: [{ product_id: '', quantity: 1, price_at_time: 0 }] });
      fetchOrders();
    } catch (error: any) {
      toast.error("Error creating order: " + error.message);
    }
  };

  const filteredOrders = orders.filter(o => o.order_type === activeTab);
  const inboundCount = orders.filter(o => o.order_type === 'inbound').length;
  const outboundCount = orders.filter(o => o.order_type === 'outbound').length;

  const StatusIcon = ({status}: {status: string}) => {
    if (status === 'completed') return <CheckCircle2 className="text-green-500" size={16}/>;
    if (status === 'cancelled') return <XCircle className="text-red-500" size={16}/>;
    if (status === 'processing') return <Loader2 className="animate-spin text-blue-500" size={16}/>;
    return <Clock className="text-yellow-500" size={16}/>;
  };

  return (
    <div className="space-y-6">
      {/* 1. Header Responsive Fix */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 px-1">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Orders</h1>
          <p className="text-gray-500 mt-1 text-sm">Manage inbound shipments and outbound deliveries.</p>
        </div>
        <button 
          onClick={() => { setNewOrder({...newOrder, order_type: activeTab}); setIsModalOpen(true); }} 
          className="btn-primary flex items-center justify-center gap-2 w-full sm:w-auto py-3 px-6 rounded-xl font-bold text-xs uppercase tracking-widest transition-all hover:scale-[1.02] active:scale-95"
        >
          <Plus size={18} /> Create Order
        </button>
      </div>

      {/* 2. Tabs Responsive Fix */}
      <div className="glass-panel p-1.5 flex gap-1 w-full sm:w-fit overflow-x-auto no-scrollbar">
        <button 
           onClick={() => setActiveTab('inbound')}
           className={cn(
             "flex-1 sm:flex-none px-6 py-2.5 rounded-lg font-bold text-xs uppercase tracking-widest transition-all flex items-center justify-center gap-2 whitespace-nowrap",
             activeTab === 'inbound' ? 'bg-primary text-white shadow-md' : 'text-zinc-500 hover:text-white hover:bg-zinc-100 dark:hover:bg-zinc-800'
           )}
        >
          Inbound ({inboundCount})
        </button>
        <button 
           onClick={() => setActiveTab('outbound')}
           className={cn(
             "flex-1 sm:flex-none px-6 py-2.5 rounded-lg font-bold text-xs uppercase tracking-widest transition-all flex items-center justify-center gap-2 whitespace-nowrap",
             activeTab === 'outbound' ? 'bg-primary text-white shadow-md' : 'text-zinc-500 hover:bg-zinc-100 hover:text-white dark:hover:bg-zinc-800'
           )}
        >
          Outbound ({outboundCount})
        </button>
      </div>

      {/* 3. Table (Desktop) / Cards (Mobile) Merge */}
      <div className="glass-panel overflow-hidden border border-gray-100">
        {loading ? (
           <div className="p-12 flex justify-center"><Loader2 className="animate-spin text-primary" size={32} /></div>
        ) : filteredOrders.length === 0 ? (
          <div className="text-center py-12 text-gray-400 font-medium uppercase tracking-widest text-xs">No {activeTab} orders found.</div>
        ) : (
          <>
            {/* Desktop Table View */}
            <div className="hidden md:block overflow-x-auto">
              <table className="glass-table w-full">
                <thead>
                  <tr className="border-b border-gray-50">
                    <th className="text-left px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Order #</th>
                    <th className="text-left px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Date</th>
                    <th className="text-left px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Value</th>
                    <th className="text-left px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Status</th>
                    <th className="text-right px-6 py-4 text-xs font-bold uppercase tracking-widest text-gray-500">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredOrders.map((order) => (
                    <tr key={order.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50 transition-colors">
                      <td className="px-6 py-4 font-mono font-bold text-foreground">{order.order_number}</td>
                      <td className="px-6 py-4 text-sm">{new Date(order.order_date).toLocaleDateString()}</td>
                      <td className="px-6 py-4 font-bold text-foreground">${order.total_value.toLocaleString(undefined, {minimumFractionDigits: 2})}</td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <StatusIcon status={order.status} />
                          <span className="capitalize font-semibold text-xs text-foreground">{order.status}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex justify-end gap-2 items-center">
                          {order.status !== 'completed' && order.status !== 'cancelled' && (
                            <select 
                               className="text-[10px] border border-gray-300 rounded-md p-1 bg-white text-gray-900 font-medium outline-none hover:border-primary transition-colors"
                               value={order.status}
                               onChange={(e) => updateStatus(order.id, e.target.value)}
                            >
                               <option value="pending" className="text-gray-900">Pending</option>
                               <option value="processing" className="text-gray-900">Processing</option>
                               <option value="completed" className="text-gray-900">Complete</option>
                               <option value="cancelled" className="text-gray-900">Cancel</option>
                            </select>
                          )}
                          <button className="p-2 text-gray-400 hover:text-primary hover:bg-primary/5 rounded-full transition-all">
                            <Eye size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Mobile Card View */}
            <div className="md:hidden space-y-4 p-4 bg-gray-50/30">
              {filteredOrders.map((order) => (
                <div key={order.id} className="glass-panel p-5 rounded-2xl space-y-4 shadow-sm border border-gray-100">
                  <div className="flex justify-between items-start">
                    <div>
                      <p className="font-mono text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">#{order.order_number}</p>
                      <h3 className="font-black text-xl text-gray-900">${order.total_value.toLocaleString(undefined, {minimumFractionDigits: 2})}</h3>
                    </div>
                    <div className="flex flex-col items-end gap-2">
                       <div className="flex items-center gap-1.5 bg-white px-2.5 py-1 rounded-full border border-gray-100 shadow-sm">
                          <StatusIcon status={order.status} />
                          <span className="capitalize font-black text-[10px] text-gray-700 tracking-tight">{order.status}</span>
                       </div>
                    </div>
                  </div>

                  <div className="flex justify-between items-center text-[11px] font-bold text-gray-500 uppercase tracking-tighter border-t border-gray-50 pt-3">
                    <span>{new Date(order.order_date).toLocaleDateString()}</span>
                    <div className="flex items-center gap-3">
                      {order.status !== 'completed' && order.status !== 'cancelled' && (
                        <select
                          className="text-[10px] border border-gray-200 rounded-lg p-1 bg-white text-gray-900 font-medium outline-none"
                          value={order.status}
                          onChange={(e) => updateStatus(order.id, e.target.value)}
                        >
                          <option value="pending" className="text-gray-900">Pending</option>
                          <option value="processing" className="text-gray-900">Processing</option>
                          <option value="completed" className="text-gray-900">Complete</option>
                          <option value="cancelled" className="text-gray-900">Cancel</option>
                        </select>
                      )}
                      <button className="p-2 bg-primary/5 text-primary rounded-lg">
                        <Eye size={18} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>

      {/* 4. Create Order Modal Responsive Fix */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-[100] flex items-center justify-center p-2 sm:p-4">
          <div className="glass-modal w-full max-w-3xl max-h-[95vh] flex flex-col shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex justify-between items-center p-5 sm:p-6 border-b border-gray-100 flex-shrink-0">
              <h2 className="text-xl font-bold text-gray-900">Create Order</h2>
              <button onClick={() => setIsModalOpen(false)} className="p-1 hover:bg-gray-100 rounded-full transition-colors">
                <X size={24} className="text-gray-400" />
              </button>
            </div>
            
            <form onSubmit={handleCreateSubmit} className="flex flex-col flex-1 overflow-hidden">
              <div className="p-5 sm:p-6 space-y-6 overflow-y-auto flex-1">
                
                {/* 5. Modal Grid Fix */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-1">
                    <label className="text-[10px] font-black uppercase tracking-widest text-gray-500">Order Type *</label>
                    <select className="glass-input w-full bg-white/80" value={newOrder.order_type} onChange={e => setNewOrder({...newOrder, order_type: e.target.value})}>
                      <option value="inbound">Inbound (Receiving)</option>
                      <option value="outbound">Outbound (Shipping)</option>
                    </select>
                  </div>
                  <div className="space-y-1">
                    <label className="text-[10px] font-black uppercase tracking-widest text-gray-500">Supplier/Customer</label>
                    <select className="glass-input w-full bg-white/80" value={newOrder.supplier_id} onChange={e => setNewOrder({...newOrder, supplier_id: e.target.value})}>
                      <option value="">Select Partner...</option>
                      {suppliers.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                    </select>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <label className="text-[10px] font-black uppercase tracking-widest text-gray-500">Line Items *</label>
                    <button type="button" onClick={() => setNewOrder({...newOrder, items: [...newOrder.items, {product_id: '', quantity: 1, price_at_time: 0}]})} className="text-xs font-bold flex items-center gap-1 text-primary">
                      <PlusCircle size={14}/> Add Item
                    </button>
                  </div>
                  
                  <div className="space-y-3">
                    {newOrder.items.map((item, idx) => (
                      <div key={idx} className="flex flex-col md:flex-row md:items-center gap-3 bg-gray-50/50 p-4 rounded-xl border border-gray-100">
                        <div className="flex-1 w-full">
                          <select 
                            required
                            className="glass-input w-full bg-white text-sm py-2" 
                            value={item.product_id} 
                            onChange={e => {
                               const prod = products.find(p => p.id.toString() === e.target.value);
                               const newItems = [...newOrder.items];
                               newItems[idx].product_id = e.target.value;
                               if (prod) newItems[idx].price_at_time = prod.price;
                               setNewOrder({...newOrder, items: newItems});
                            }}
                          >
                            <option value="">Select Product...</option>
                            {products.map(p => <option key={p.id} value={p.id}>{p.sku} - {p.name}</option>)}
                          </select>
                        </div>
                        
                        {/* Mobile Item Controls */}
                        <div className="flex items-center gap-2 w-full md:w-auto">
                          <div className="flex-1 md:w-24">
                            <input required type="number" min="1" placeholder="Qty" className="glass-input bg-white w-full text-sm py-2" 
                             value={item.quantity} onChange={e => {
                               const newItems = [...newOrder.items];
                               newItems[idx].quantity = parseInt(e.target.value);
                               setNewOrder({...newOrder, items: newItems});
                             }} />
                          </div>
                          <div className="flex-1 md:w-28">
                            <input required type="number" step="0.01" min="0" placeholder="Price" className="glass-input bg-white w-full text-sm py-2" 
                             value={item.price_at_time} onChange={e => {
                               const newItems = [...newOrder.items];
                               newItems[idx].price_at_time = parseFloat(e.target.value);
                               setNewOrder({...newOrder, items: newItems});
                             }} />
                          </div>
                          <button type="button" onClick={() => {
                             const newItems = newOrder.items.filter((_, i) => i !== idx);
                             setNewOrder({...newOrder, items: newItems.length ? newItems : [{product_id: '', quantity: 1, price_at_time: 0}]});
                          }} className="text-red-400 hover:text-red-600 p-2 hover:bg-red-50 rounded-lg shrink-0">
                            <Trash2 size={18}/>
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="text-[10px] font-black uppercase tracking-widest text-gray-500">Internal Notes</label>
                  <textarea className="glass-input w-full bg-white/80 resize-none text-sm" rows={2} value={newOrder.notes} onChange={e => setNewOrder({...newOrder, notes: e.target.value})} placeholder="Shipping instructions or comments..."></textarea>
                </div>

              </div>
              
              <div className="p-5 sm:p-6 border-t border-gray-100 flex flex-col sm:flex-row justify-between items-center gap-4 bg-gray-50/80 rounded-b-2xl">
                <div className="flex flex-col items-center sm:items-start">
                  <span className="text-[10px] font-black uppercase tracking-widest text-gray-400">Grand Total</span>
                  <span className="font-black text-2xl text-gray-900">
                    ${newOrder.items.reduce((sum, item) => sum + (item.quantity * item.price_at_time), 0).toLocaleString(undefined, {minimumFractionDigits: 2})}
                  </span>
                </div>
                <div className="flex gap-3 w-full sm:w-auto">
                  <button type="button" onClick={() => setIsModalOpen(false)} className="btn-secondary flex-1 sm:flex-none py-3 px-6 text-xs font-bold uppercase tracking-widest">Cancel</button>
                  <button type="submit" className="btn-primary flex-1 sm:flex-none py-3 px-6 text-xs font-bold uppercase tracking-widest">Create Order</button>
                </div>
              </div>
            </form>

          </div>
        </div>
      )}
    </div>
  );
}