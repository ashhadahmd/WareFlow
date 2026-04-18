'use client';

import { use, useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import Cookies from 'js-cookie';
import { 
  LayoutDashboard, 
  Package, 
  ArrowLeftRight, 
  Users, 
  BarChart3, 
  Settings,
  LogOut,
  Building2,
  Menu,
  X
} from 'lucide-react';
import { api } from '@/lib/api';
import { ThemeToggle } from '@/components/ThemeToggle';
import { Logo } from '@/components/Logo';

// Simple helper for tailwind classes since @/lib/utils might be missing
const cn = (...classes: any[]) => classes.filter(Boolean).join(' ');

export default function AppLayout({
  children,
  params
}: {
  children: React.ReactNode;
  params: Promise<{ warehouseId: string }>;
}) {
  const unwrappedParams = use(params);
  const pathname = usePathname();
  const router = useRouter();
  const [warehouseName, setWarehouseName] = useState('Loading...');
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [userRole, setUserRole] = useState<string>('');
  const [userPerms, setUserPerms] = useState<string[]>([]);

  useEffect(() => {
    const token = Cookies.get('token');
    const whId = Cookies.get('warehouseId');
    
    if (!token || !whId) {
      router.push('/login');
      return;
    }

    const fetchContext = async () => {
      try {
        const whs = await api.get('/warehouses/');
        const currentWh = (whs as any[]).find(w => w.id === parseInt(unwrappedParams.warehouseId));
        if (currentWh) {
          setWarehouseName(currentWh.name);
          
          try {
            const me: any = await api.get(`/warehouses/${unwrappedParams.warehouseId}/me`);
            setUserRole(me.role);
            setUserPerms(me.permissions.map((p: any) => p.name));
          } catch (meError) {
             console.error("Failed to load user permissions", meError);
          }
        } else {
             router.push('/warehouses');
        }
      } catch (e) {
        console.error("Failed to load warehouse context", e);
      }
    };
    
    fetchContext();
  }, [unwrappedParams.warehouseId, router]);

  // Close sidebar on route change (for mobile)
  useEffect(() => {
    setIsSidebarOpen(false);
  }, [pathname]);

  const navigation = [
    { name: 'Dashboard', href: `/${unwrappedParams.warehouseId}`, icon: LayoutDashboard },
    { name: 'Inventory', href: `/${unwrappedParams.warehouseId}/inventory`, icon: Package },
    { name: 'Orders', href: `/${unwrappedParams.warehouseId}/orders`, icon: ArrowLeftRight },
    { name: 'Suppliers', href: `/${unwrappedParams.warehouseId}/suppliers`, icon: Users },
    { name: 'Reports', href: `/${unwrappedParams.warehouseId}/reports`, icon: BarChart3 },
    { name: 'Settings', href: `/${unwrappedParams.warehouseId}/settings`, icon: Settings },
  ];

  const hasAccess = (item: any) => {
    if (userRole === 'Owner' || userRole === 'Admin') return true;
    if (item.name === 'Dashboard') return true;
    if (item.name === 'Inventory') return userPerms.some(p => p.startsWith('inventory:'));
    if (item.name === 'Orders') return userPerms.some(p => p.startsWith('orders:'));
    if (item.name === 'Suppliers') return userPerms.some(p => p.startsWith('suppliers:'));
    if (item.name === 'Reports') return userPerms.some(p => p.startsWith('reports:'));
    if (item.name === 'Settings') return userPerms.includes('users:manage');
    return false;
  };

  const filteredNavigation = navigation.filter(hasAccess);

  const handleSwitchWarehouse = () => {
    Cookies.remove('warehouseId');
    router.push('/warehouses');
  };

  return (
    <div className="min-h-screen flex bg-[#f8fafc] dark:bg-background">
      
      {/* --- Mobile Top Header --- */}
      <div className="lg:hidden fixed top-0 left-0 w-full h-16 bg-white/80 dark:bg-card/80 backdrop-blur-md border-b border-gray-200 dark:border-border z-[60] flex items-center justify-between px-4">
        <Link href={`/${unwrappedParams.warehouseId}`} className="flex items-center gap-2 cursor-pointer">
          <Logo className="w-8 h-8 text-foreground" />
          <span className="text-lg font-black tracking-tighter uppercase text-foreground">WareFlow</span>
        </Link>
        <button 
          onClick={() => setIsSidebarOpen(!isSidebarOpen)}
          className="p-2 hover:bg-gray-100 dark:hover:bg-accent rounded-lg transition-colors cursor-pointer"
        >
          {isSidebarOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      {/* --- Mobile Overlay --- */}
      {isSidebarOpen && (
        <div 
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-[55] lg:hidden"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}

      {/* --- Sidebar --- */}
      <div className={cn(
        "w-64 fixed inset-y-0 z-[59] flex flex-col glass-panel rounded-none border-y-0 border-l-0 transition-transform duration-300 lg:translate-x-0 shadow-xl",
        isSidebarOpen ? "translate-x-0" : "-translate-x-full"
      )}>
        <div className="p-6">
          <Link href={`/${unwrappedParams.warehouseId}`} className="flex items-center gap-2 group cursor-pointer">
           <img 
                src="/logo.svg" 
                alt="WareFlow Logo" 
                className="w-8 h-8 sm:w-10 sm:h-10 object-contain transition-all" 
              />
            <span className="text-xl font-black tracking-tighter uppercase text-foreground">WareFlow</span>
          </Link>
        </div>
        
        <div className="px-4 pb-4">
          <button 
             onClick={handleSwitchWarehouse}
             className="w-full text-left p-3.5 rounded-2xl border border-gray-200 dark:border-border bg-white/50 dark:bg-white/5 hover:bg-white dark:hover:bg-accent transition-all flex items-center justify-between group cursor-pointer"
          >
            <div className="overflow-hidden">
               <p className="text-[10px] text-gray-500 font-black uppercase tracking-widest">WORKSPACE</p>
               <p className="font-bold text-gray-900 truncate dark:text-foreground">{warehouseName}</p>
            </div>
            <Building2 size={16} className="text-gray-400 group-hover:text-primary transition-colors shrink-0" />
          </button>
        </div>

        <nav className="flex-1 px-4 space-y-1.5 overflow-y-auto no-scrollbar">
          {filteredNavigation.map((item) => {
            const isActive = item.href === `/${unwrappedParams.warehouseId}` 
                ? pathname === item.href 
                : pathname.startsWith(item.href);
            
            return (
              <Link
                key={item.name}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 px-4 py-3 rounded-xl font-bold text-sm transition-all group cursor-pointer",
                  isActive 
                    ? 'bg-primary text-primary-foreground shadow-lg shadow-primary/20 translate-x-1' 
                    : 'text-gray-500 hover:bg-black/5 dark:hover:bg-accent dark:hover:text-foreground'
                )}
              >
                <item.icon size={20} className={isActive ? 'text-primary-foreground' : 'text-gray-400 group-hover:text-foreground'} />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <div className="p-6 mt-auto space-y-4 border-t border-border/40">
          <div className="flex justify-center transition-transform hover:scale-110 cursor-pointer">
            <ThemeToggle />
          </div>
          <button 
            onClick={() => {
              Cookies.remove('token');
              Cookies.remove('warehouseId');
              router.push('/login');
            }}
            className="flex items-center justify-center gap-3 px-4 py-3 w-full rounded-xl font-black text-xs uppercase tracking-widest text-gray-400 hover:bg-rose-50 hover:text-rose-600 dark:hover:bg-rose-950/20 dark:hover:text-rose-400 transition-all cursor-pointer border border-transparent hover:border-rose-200 dark:hover:border-rose-900"
          >
            <LogOut size={18} />
            Logout
          </button>
        </div>
      </div>

      {/* --- Main Content Area --- */}
      <div className="flex-1 lg:ml-64 min-h-screen pt-16 lg:pt-0">
        <main className="p-4 sm:p-10 max-w-7xl mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}