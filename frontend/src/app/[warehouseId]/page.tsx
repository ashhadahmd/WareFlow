'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { useTheme } from 'next-themes';
import { 
  TrendingUp, 
  Package, 
  CheckCircle2, 
  Users,
  Loader2
} from 'lucide-react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
} from 'recharts';

const COLORS = ['#0f172a', '#3b82f6', '#10b981', '#f59e0b', '#ef4444'];

export default function DashboardPage() {
  const [loading, setLoading] = useState(true);
  const [summary, setSummary] = useState<any>(null);
  const [trendData, setTrendData] = useState<any[]>([]);
  const [categoryData, setCategoryData] = useState<any[]>([]);

  const { resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  const isDark = mounted && resolvedTheme === 'dark';

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [sum, trend, cats] = await Promise.all([
          api.get('/reports/summary'),
          api.get('/reports/revenue-trend'),
          api.get('/reports/inventory-by-category')
        ]);
        
        setSummary(sum);
        
        const t = (trend as any).labels.map((label: string, i: number) => ({
          name: label,
          revenue: (trend as any).data[i]
        }));
        setTrendData(t);
        setCategoryData(cats as any[]);
        
      } catch (error) {
        console.error("Error loading dashboard", error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, []);

  if (loading || !summary) {
    return (
      <div className="flex items-center justify-center h-[50vh]">
        <Loader2 className="animate-spin text-gray-400" size={32} />
      </div>
    );
  }

  const statCards = [
    { 
      title: 'Total Revenue', 
      value: `$${summary.total_revenue.toLocaleString(undefined, {minimumFractionDigits: 2})}`, 
      change: summary.total_revenue_change,
      icon: TrendingUp,
      positive: true
    },
    { 
      title: 'Inventory Value', 
      value: `$${summary.inventory_value.toLocaleString(undefined, {minimumFractionDigits: 2})}`, 
      change: summary.inventory_value_change,
      icon: Package,
      positive: true
    },
    { 
      title: 'Completed Orders', 
      value: summary.completed_orders.toString(), 
      change: summary.completed_orders_change,
      icon: CheckCircle2,
      positive: true
    },
    { 
      title: 'Active Suppliers', 
      value: summary.active_suppliers.toString(), 
      change: summary.active_suppliers_change,
      icon: Users,
      positive: false
    }
  ];

  return (
    <div className="space-y-6">
      <div className="mb-4 sm:mb-8">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-foreground">Dashboard Overview</h1>
        <p className="text-gray-500 mt-1 text-sm sm:text-base">Here's what's happening in your warehouse today.</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        {statCards.map((stat, i) => (
          <div key={i} className="glass-panel p-6 shadow-sm border border-gray-100 dark:border-border">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-sm font-medium text-gray-500">{stat.title}</p>
                <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-foreground mt-2">{stat.value}</h3>
              </div>
              <div className="p-3 bg-gray-50 dark:bg-accent rounded-xl text-primary shrink-0">
                <stat.icon size={20} />
              </div>
            </div>
            <div className="mt-4 flex items-center">
              <span className={`text-xs font-semibold px-2 py-1 rounded-full ${stat.positive ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}`}>
                {stat.change}
              </span>
              <span className="text-xs text-gray-500 ml-2">vs last month</span>
            </div>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
        
        {/* Revenue Trend Chart */}
        <div className="lg:col-span-2 glass-panel p-4 sm:p-6 border border-gray-100 dark:border-border">
          <h3 className="font-semibold text-gray-900 dark:text-foreground mb-6">Revenue Trend</h3>
          <div className="h-64 sm:h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={trendData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 10 }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 10 }} dx={-10} tickFormatter={(val) => `$${val / 1000}k`} />
                <Tooltip
                  contentStyle={{
                    borderRadius: '0.5rem',
                    border: 'none',
                    boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)',
                    backgroundColor: isDark ? '#1e293b' : '#ffffff',
                    color: isDark ? '#f1f5f9' : '#0f172a',
                  }}
                  // ✅ Fix: any type — TypeScript red error gone
                  formatter={(value: any) => [`$${Number(value).toLocaleString()}`, 'Revenue']}
                />
                <Line
                  type="monotone"
                  dataKey="revenue"
                  stroke={isDark ? '#ffffff' : '#0f172a'}
                  strokeWidth={3}
                  dot={{ r: 4, fill: isDark ? '#ffffff' : '#0f172a' }}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Pie Chart */}
        <div className="glass-panel p-4 sm:p-6 flex flex-col border border-gray-100 dark:border-border">
          <h3 className="font-semibold text-gray-900 dark:text-foreground mb-2">Inventory by Category</h3>
          <div className="flex-1 min-h-[250px] w-full">
            {/* ✅ Fix: Empty state jab koi stock nahi */}
            {categoryData.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full gap-2 text-gray-400">
                <Package size={32} className="opacity-30" />
                <p className="text-xs font-bold uppercase tracking-widest">No inventory data</p>
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                    nameKey="category"
                    stroke="none"
                  >
                    {categoryData.map((_, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      borderRadius: '0.5rem',
                      border: 'none',
                      boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)',
                      backgroundColor: isDark ? '#1e293b' : '#ffffff',
                      color: isDark ? '#f1f5f9' : '#0f172a',
                    }}
                    // ✅ Fix: any type — TypeScript red error gone
                    formatter={(value: any) => [value, 'Items']}
                  />
                  <Legend
                    layout="horizontal"
                    verticalAlign="bottom"
                    align="center"
                    iconType="circle"
                    wrapperStyle={{ fontSize: '10px' }}
                  />
                </PieChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>

      </div>
    </div>
  );
}