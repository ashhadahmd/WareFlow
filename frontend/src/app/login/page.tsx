'use client';

import { useState, useEffect, Suspense } from 'react'; // Suspense import kiya
import { useRouter, useSearchParams } from 'next/navigation';
import Cookies from 'js-cookie';
import { Loader2, LogIn, UserPlus } from 'lucide-react';
import { api } from '@/lib/api';
import { ThemeToggle } from '@/components/ThemeToggle';

// 1. Saara logic aur UI is naye component mein move kar diya
function LoginContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [isLogin, setIsLogin] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState({
    email: '',
    password: '',
    name: ''
  });

  useEffect(() => {
    const emailParam = searchParams.get('email');
    if (emailParam) {
      setFormData(prev => ({ ...prev, email: emailParam }));
    }
  }, [searchParams]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (isLogin) {
        const payload = new FormData();
        payload.append('username', formData.email);
        payload.append('password', formData.password);
        
        const res = await api.login(payload);
        Cookies.set('token', res.access_token, { expires: 7 });
        
        const inviteToken = Cookies.get('pending_invite_token');
        if (inviteToken) {
          try {
            await api.post(`/warehouses/invitation/${inviteToken}/accept`, {}); // Empty body fix
            Cookies.remove('pending_invite_token');
          } catch (e) {
            console.error('Failed to accept invite token:', e);
          }
        }
        
        router.push('/warehouses');
      } else {
        await api.post('/auth/register', formData);
        setIsLogin(true);
        setError('Registration successful! Please login.');
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="glass-modal w-full max-w-md p-6 sm:p-8 shadow-2xl">
      <div className="text-center mb-8">
        <h1 className="text-xl sm:text-2xl font-black tracking-tighter text-foreground uppercase">WareFlow</h1>
        <p className="text-muted-foreground mt-2 text-sm sm:text-base">
          {isLogin ? 'Welcome back' : 'Create an account'}
        </p>
      </div>

      {error && (
        <div className={`p-3 rounded mb-6 text-xs sm:text-sm font-medium border ${
          error.includes('successful') 
          ? 'bg-green-500/10 text-green-500 border-green-500/20' 
          : 'bg-red-500/10 text-red-500 border-red-500/20'
        }`}>
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-4 sm:space-y-5">
        {!isLogin && (
          <div>
            <label className="block text-xs sm:text-sm font-bold uppercase tracking-widest text-muted-foreground mb-2">Name</label>
            <input 
              type="text" 
              required 
              placeholder="Full Name"
              className="glass-input w-full" 
              value={formData.name}
              onChange={e => setFormData({...formData, name: e.target.value})}
            />
          </div>
        )}
        
        <div>
          <label className="block text-xs sm:text-sm font-bold uppercase tracking-widest text-muted-foreground mb-2">Email Address</label>
          <input 
            type="email" 
            required 
            placeholder="name@example.com"
            className="glass-input w-full" 
            value={formData.email}
            onChange={e => setFormData({...formData, email: e.target.value})}
          />
        </div>

        <div>
          <label className="block text-xs sm:text-sm font-bold uppercase tracking-widest text-muted-foreground mb-2">Password</label>
          <input 
            type="password" 
            required 
            placeholder="••••••••"
            className="glass-input w-full" 
            value={formData.password}
            onChange={e => setFormData({...formData, password: e.target.value})}
          />
        </div>

        <button 
          type="submit" 
          disabled={loading}
          className="w-full btn-primary flex justify-center items-center gap-2 mt-8 py-3 rounded-xl font-bold transition-transform active:scale-95 text-sm sm:text-base cursor-pointer"
        >
          {loading ? 'Processing...' : isLogin ? (
            <><LogIn size={18} /> Sign In</>
          ) : (
            <><UserPlus size={18} /> Register</>
          )}
        </button>
      </form>

      <div className="mt-8 text-center text-xs sm:text-sm">
        <button 
          onClick={() => { setIsLogin(!isLogin); setError(''); }}
          className="text-muted-foreground hover:text-foreground transition-colors font-semibold cursor-pointer"
        >
          {isLogin ? "Don't have an account? Sign up" : 'Already have an account? Sign in'}
        </button>
      </div>
    </div>
  );
}

// 2. Main Page export ko Suspense mein wrap kiya
export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center p-4 relative bg-background">
      <div className="absolute top-4 right-4 sm:top-6 sm:right-6">
         <ThemeToggle />
      </div>

      <Suspense fallback={
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="animate-spin text-primary" size={40} />
          <p className="text-xs font-bold uppercase tracking-widest text-muted-foreground">Initializing Security...</p>
        </div>
      }>
        <LoginContent />
      </Suspense>
    </div>
  );
}