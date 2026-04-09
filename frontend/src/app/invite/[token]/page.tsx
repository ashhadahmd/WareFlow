'use client';

import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { CheckCircle2, XCircle, Loader2 } from 'lucide-react';
import { api } from '@/lib/api';
import Cookies from 'js-cookie';

export default function InvitePage() {
  const router = useRouter();
  const params = useParams();
  const token = params.token as string;

  const [loading, setLoading] = useState(true);
  const [invite, setInvite] = useState<any>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!token) return;

    // Check if token is valid
    api.get(`/warehouses/invitation/${token}`)
      .then((data: any) => {
        setInvite(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message || 'Invitation is invalid or has expired.');
        setLoading(false);
      });
  }, [token]);

  const handleApplyToken = () => {
    // Save the intended token to cookies so the login/register flows can process it after auth
    Cookies.set('pending_invite_token', token, { expires: 1 });
    router.push(`/login?email=${encodeURIComponent(invite.email)}`);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 relative">
      <div className="glass-modal w-full max-w-md p-8 text-center">
        {loading ? (
          <div className="flex flex-col items-center gap-4">
            <Loader2 className="animate-spin text-primary" size={32} />
            <p className="text-gray-500 dark:text-gray-400">Verifying invitation...</p>
          </div>
        ) : error ? (
           <div className="flex flex-col items-center gap-4">
            <XCircle className="text-red-500" size={48} />
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Invitation Invalid</h1>
            <p className="text-gray-500 dark:text-gray-400">{error}</p>
            <button onClick={() => router.push('/login')} className="btn-secondary mt-4 w-full">Return to Login</button>
          </div>
        ) : (
           <div className="flex flex-col items-center gap-4">
            <CheckCircle2 className="text-green-500" size={48} />
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">You've Been Invited!</h1>
            <p className="text-gray-600 dark:text-gray-300">
              You have been invited to join a tracking Warehouse on <b>WareFlow</b> as a <span className="font-semibold text-primary">{invite?.role}</span>.
            </p>
            
            <div className="w-full bg-white/50 dark:bg-black/20 p-4 rounded-xl border border-gray-100 dark:border-white/5 my-4">
              <p className="text-sm text-gray-500 dark:text-gray-400 mb-1">Invited Email:</p>
              <p className="font-medium text-gray-900 dark:text-white">{invite?.email}</p>
            </div>

            <button onClick={handleApplyToken} className="btn-primary w-full shadow-lg shadow-primary/20">
              Accept Invitation
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
