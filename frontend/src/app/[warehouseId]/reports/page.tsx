'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { 
  TrendingUp, 
  Package, 
  CheckCircle2, 
  Users,
  AlertTriangle,
  Loader2
} from 'lucide-react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
} from 'recharts';

const COLORS = ['#9f55c1ff', '#3b82f6', '#10b981', '#f59e0b', '#ef4444'];

export default function ReportsPage() {
  const [loading, setLoading] = useState(true);
  const [summary, setSummary] = useState<any>(null);
  const [trendData, setTrendData] = useState<any[]>([]);
  const [categoryData, setCategoryData] = useState<any[]>([]);
  const [alerts, setAlerts] = useState<any[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [sum, trend, cats, stockAlerts] = await Promise.all([
          api.get('/reports/summary'),
          api.get('/reports/revenue-trend'),
          api.get('/reports/inventory-by-category'),
          api.get('/reports/low-stock-alerts')
        ]);
        
        setSummary(sum);
        
        const t = (trend as any).labels.map((label: string, i: number) => ({
          name: label,
          revenue: (trend as any).data[i]
        }));
        setTrendData(t);
        setCategoryData(cats as any[]);
        setAlerts(stockAlerts as any[]);
        
      } catch (error) {
        console.error("Error loading reports", error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, []);

  if (loading || !summary) {
    return <div className="flex items-center justify-center h-64"><Loader2 className="animate-spin text-gray-400" size={32} /></div>;
  }

  const statCards = [
    { title: 'Total Revenue', value: `$${summary.total_revenue.toLocaleString(undefined, {minimumFractionDigits: 2})}`, icon: TrendingUp },
    { title: 'Inventory Value', value: `$${summary.inventory_value.toLocaleString(undefined, {minimumFractionDigits: 2})}`, icon: Package },
    { title: 'Completed Orders', value: summary.completed_orders.toString(), icon: CheckCircle2 },
    { title: 'Active Suppliers', value: summary.active_suppliers.toString(), icon: Users }
  ];

  return (
    <div className="space-y-6">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-foreground">Reports & Analytics</h1>
        <p className="text-gray-500 mt-1">Detailed insights into your warehouse operations.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {statCards.map((stat, i) => (
          <div key={i} className="glass-panel p-6 flex flex-col justify-center items-center text-center">
            <div className="p-4 bg-gray-50 rounded-full text-primary mb-4">
               <stat.icon size={28} />
            </div>
            <p className="text-sm font-medium text-gray-500">{stat.title}</p>
            <h3 className="text-2xl font-bold text-foreground mt-1">{stat.value}</h3>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="glass-panel p-6">
          <h3 className="text-lg font-bold text-foreground mb-6">Revenue Trend (8 Months)</h3>
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={trendData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748b', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748b', fontSize: 12}} dx={-10} tickFormatter={(val) => `$${val/1000}k`} />
                <Tooltip 
                   contentStyle={{ borderRadius: '0.5rem', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)', color: '#18181b' }}
                   itemStyle={{ color: '#18181b' }}
                   labelStyle={{ color: '#18181b' }}
                   formatter={(value: any) => [`$${value.toLocaleString()}`, 'Revenue']}
                />
                <Line type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={4} dot={{r: 4, fill: '#3b82f6'}} activeDot={{r: 8}} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="flex flex-col gap-6">
          <div className="glass-panel p-6 flex-1">
            <h3 className="text-lg font-bold text-foreground mb-2">Inventory Breakdown</h3>
            <div className="h-64 mt-4">
              {categoryData.length === 0 || categoryData.every(c => c.value === 0) ? (
                <div className="flex items-center justify-center h-full text-zinc-500 text-xs font-bold uppercase tracking-widest bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-100 dark:border-zinc-800">
                  No stock data available
                </div>
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={categoryData}
                      cx="50%"
                      cy="50%"
                      innerRadius={70}
                      outerRadius={100}
                      paddingAngle={5}
                      dataKey="value"
                      nameKey="category"
                      stroke="none"
                    >
                      {categoryData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip 
                       contentStyle={{ borderRadius: '0.5rem', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)', color: '#18181b' }}
                       itemStyle={{ color: '#18181b' }}
                    />
                    <Legend layout="horizontal" verticalAlign="bottom" align="center" iconType="circle" />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </div>
          </div>

          <div className="glass-panel p-6 flex-1">
            <h3 className="text-lg font-bold text-red-600 flex items-center gap-2 mb-4">
              <AlertTriangle size={20} /> Low Stock Alerts
            </h3>
            
            <div className="space-y-3 overflow-y-auto max-h-48 pr-2">
               {alerts.length === 0 ? (
                 <p className="text-gray-500 text-sm">All products are healthy.</p>
               ) : alerts.map((alert) => (
                 <div key={alert.id} className="bg-red-50 dark:bg-red-500/10 p-3 rounded-lg flex items-center justify-between border border-red-100 dark:border-red-500/20">
                    <div>
                      <p className="font-semibold text-foreground text-sm">{alert.name}</p>
                      <p className="text-xs text-gray-500">{alert.sku}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-red-600 font-bold text-lg">{alert.quantity}</p>
                      <p className="text-xs text-gray-500">Min: {alert.min_stock}</p>
                    </div>
                 </div>
               ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
