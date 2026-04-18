'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/api';
import Cookies from 'js-cookie';
import {
  Users, Shield, Loader2, UserPlus, Trash2,
  Edit2, X, AlertCircle, CheckCircle2, Copy
} from 'lucide-react';
import toast from 'react-hot-toast';

// Local helper to avoid class chaos
const cn = (...classes: any[]) => classes.filter(Boolean).join(' ');

export default function SettingsPage() {
  const [members, setMembers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('members');
  const [errorHeader, setErrorHeader] = useState('');

  // Invite Modal
  const [isInviteOpen, setIsInviteOpen] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState('Member');
  const [inviteLink, setInviteLink] = useState('');

  // Permissions Modal
  const [isPermOpen, setIsPermOpen] = useState(false);
  const [editingMember, setEditingMember] = useState<any>(null);
  const [selectedRole, setSelectedRole] = useState('');
  const [selectedPerms, setSelectedPerms] = useState<string[]>([]);

  const AVAILABLE_PERMISSIONS = [
    { id: 'inventory:read', label: 'View Inventory' },
    { id: 'inventory:write', label: 'Manage Inventory' },
    { id: 'suppliers:read', label: 'View Suppliers' },
    { id: 'suppliers:write', label: 'Manage Suppliers' },
    { id: 'orders:read', label: 'View Orders' },
    { id: 'orders:manage', label: 'Manage Orders' },
    { id: 'reports:read', label: 'View Reports' },
    { id: 'users:manage', label: 'Manage Users' },
  ];

  useEffect(() => {
    fetchMembers();
  }, []);

  const fetchMembers = async () => {
    try {
      setLoading(true);
      setErrorHeader('');
      const warehouseId = Cookies.get('warehouseId');
      if (!warehouseId) return;
      const data = await api.get(`/warehouses/${warehouseId}/members`);
      setMembers(data as any[]);
    } catch (error: any) {
      setErrorHeader("You do not have permission to view members.");
      setMembers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleInvite = async (e: React.FormEvent) => {
    e.preventDefault();
    const t = toast.loading("Generating link...");
    try {
      const warehouseId = Cookies.get('warehouseId');
      const res: any = await api.post(`/warehouses/${warehouseId}/invitations`, {
        email: inviteEmail,
        role: inviteRole
      });

      const link = `${window.location.origin}/invite/${res.token}`;
      setInviteLink(link);
      toast.success("Invitation generated!", { id: t });
      fetchMembers();
    } catch (error: any) {
      toast.error(error.message, { id: t });
    }
  };

  const handleRemove = async (userId: number) => {
    if (confirm('Are you sure you want to remove this member?')) {
      try {
        const warehouseId = Cookies.get('warehouseId');
        await api.delete(`/warehouses/${warehouseId}/members/${userId}`);
        toast.success("Member removed");
        fetchMembers();
      } catch (error: any) {
        toast.error(error.message);
      }
    }
  };

  const openPermModal = (member: any) => {
    setEditingMember(member);
    setSelectedRole(member.role);
    setSelectedPerms(member.permissions.map((p: any) => p.name));
    setIsPermOpen(true);
  };

  const savePermissions = async (e: React.FormEvent) => {
    e.preventDefault();
    const t = toast.loading("Saving...");
    try {
      const warehouseId = Cookies.get('warehouseId');
      await api.put(`/warehouses/${warehouseId}/members/${editingMember.user_id}`, {
        role: selectedRole,
        permissions: selectedPerms
      });
      setIsPermOpen(false);
      toast.success("Permissions updated", { id: t });
      fetchMembers();
    } catch (error: any) {
      toast.error(error.message, { id: t });
    }
  };

  const togglePermission = (permId: string) => {
    setSelectedPerms(prev =>
      prev.includes(permId) ? prev.filter(p => p !== permId) : [...prev, permId]
    );
  };

  return (
    <div className="space-y-6 max-w-5xl pb-10">
      {/* 1. Header Responsive */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 px-1">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black tracking-tighter uppercase text-zinc-900 dark:text-zinc-50">
            Settings
          </h1>
          <p className="text-zinc-500 dark:text-zinc-400 mt-1 text-sm font-medium">Manage team access and warehouse controls.</p>
        </div>
      </div>

      {/* 2. Tabs Responsive */}
      <div className="glass-panel p-1.5 flex gap-1 w-full sm:w-fit overflow-x-auto no-scrollbar">
        <button
          onClick={() => setActiveTab('members')}
          className={cn(
            "flex-1 sm:flex-none px-6 py-2.5 rounded-lg font-bold text-xs uppercase tracking-widest transition-all flex items-center justify-center gap-2 whitespace-nowrap",
            activeTab === 'members' ? 'bg-primary text-white shadow-md' : 'text-zinc-500 hover:text-white hover:bg-zinc-700 dark:hover:bg-zinc-800 dark:hover:text-white'
          )}
        >
          <Users size={16} /> Members
        </button>
        <button
          onClick={() => setActiveTab('roles')}
          className={cn(
            "flex-1 sm:flex-none px-6 py-2.5 rounded-lg hover:text-white font-bold text-xs uppercase tracking-widest transition-all flex items-center justify-center gap-2 whitespace-nowrap",
            activeTab === 'roles'
              ? 'bg-primary text-white shadow-md'
              : 'text-zinc-500 hover:text-white hover:bg-zinc-700 dark:hover:bg-zinc-800 dark:hover:text-white'
          )}
        >
          <Shield size={16} /> Roles Profile
        </button>
      </div>

      {errorHeader && (
        <div className="bg-rose-50 border border-rose-200 text-rose-700 p-4 rounded-2xl flex items-center gap-3 animate-in fade-in slide-in-from-top-2">
          <AlertCircle size={20} />
          <span className="font-bold text-sm uppercase tracking-tight">{errorHeader}</span>
        </div>
      )}

      {/* 3. Members Section - Desktop Table / Mobile Cards */}
      {!errorHeader && activeTab === 'members' && (
        <div className="glass-panel overflow-hidden border border-border/50">
          <div className="p-4 sm:p-6 border-b border-border/50 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-muted/20">
            <h3 className="font-black uppercase tracking-widest text-xs text-zinc-500">Team Roster</h3>
            <button
              onClick={() => setIsInviteOpen(true)}
              className="btn-primary text-xs font-bold uppercase tracking-widest flex items-center justify-center gap-2 w-full sm:w-auto py-2.5 px-5"
            >
              <UserPlus size={16} /> Invite Member
            </button>
          </div>

          {loading ? (
            <div className="p-20 flex justify-center"><Loader2 className="animate-spin text-primary" size={32} /></div>
          ) : (
            <>
              {/* Desktop Table View */}
              <div className="hidden md:block overflow-x-auto">
                <table className="glass-table w-full">
                  <thead>
                    <tr className="text-left border-b border-border/50">
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-zinc-500">User</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-zinc-500">Role</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-zinc-500">Permissions</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-zinc-500">Joined</th>
                      <th className="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-zinc-500 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/30">
                    {members.map((member) => (
                      <tr key={member.id} className="hover:bg-muted/30 transition-colors">
                        <td className="px-6 py-4">
                          <div className="flex flex-col">
                            <span className="font-bold text-zinc-900 dark:text-foreground">{member.user.name}</span>
                            <span className="text-xs text-zinc-500">{member.user.email}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className={cn(
                            "px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest border",
                            member.role === 'Owner' ? "bg-amber-500/10 text-amber-600 border-amber-500/20" : "bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400"
                          )}>
                            {member.role}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          {member.role === 'Owner' || member.role === 'Admin' ? (
                            <span className="text-[10px] font-black uppercase text-zinc-400">Full Access</span>
                          ) : (
                            <div className="flex flex-wrap gap-1 max-w-[200px]">
                              {member.permissions.length === 0 ? (
                                <span className="text-[10px] font-black text-zinc-400 uppercase">None</span>
                              ) : member.permissions.map((p: any) => (
                                <span key={p.id} className="text-[9px] font-black uppercase bg-primary/5 text-primary px-1.5 py-0.5 rounded border border-primary/10">
                                  {p.name.split(':')[0]}
                                </span>
                              ))}
                            </div>
                          )}
                        </td>
                        <td className="px-6 py-4 text-xs font-bold text-zinc-500">{new Date(member.joined_at).toLocaleDateString()}</td>
                        <td className="px-6 py-4">
                          <div className="flex justify-end gap-2">
                            {member.role !== 'Owner' && (
                              <>
                                <button onClick={() => openPermModal(member)} className="p-2 text-zinc-400 hover:text-primary hover:bg-primary/10 rounded-lg transition-all"><Edit2 size={16} /></button>
                                <button onClick={() => handleRemove(member.user_id)} className="p-2 text-zinc-400 hover:text-rose-500 hover:bg-rose-500/10 rounded-lg transition-all"><Trash2 size={16} /></button>
                              </>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Mobile Card View */}
              <div className="md:hidden space-y-4 p-4">
                {members.map((member) => (
                  <div key={member.id} className="glass-panel p-5 rounded-2xl border border-border/50 space-y-4 shadow-sm">
                    <div className="flex justify-between items-start">
                      <div className="min-w-0">
                        <h3 className="font-bold text-zinc-900 dark:text-zinc-100 truncate">{member.user.name}</h3>
                        <p className="text-xs text-zinc-500 truncate">{member.user.email}</p>
                      </div>
                      <span className="px-2 py-0.5 rounded-full text-[9px] font-black uppercase bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400">
                        {member.role}
                      </span>
                    </div>

                    <div className="grid grid-cols-2 gap-2 pt-2 border-t border-border/30">
                      <div className="space-y-1">
                        <p className="text-[9px] font-black text-zinc-400 uppercase">Joined</p>
                        <p className="text-[11px] font-bold">{new Date(member.joined_at).toLocaleDateString()}</p>
                      </div>
                      <div className="space-y-1">
                        <p className="text-[9px] font-black text-zinc-400 uppercase">Status</p>
                        <p className="text-[11px] font-bold text-emerald-500">Active</p>
                      </div>
                    </div>

                    {member.role !== 'Owner' && (
                      <div className="flex justify-end gap-3 pt-3 border-t border-border/30">
                        <button onClick={() => openPermModal(member)} className="p-2.5 bg-primary/5 text-primary rounded-xl flex items-center gap-2 text-xs font-bold uppercase"><Edit2 size={16} /> Edit</button>
                        <button onClick={() => handleRemove(member.user_id)} className="p-2.5 bg-rose-500/10 text-rose-500 rounded-xl flex items-center gap-2 text-xs font-bold uppercase"><Trash2 size={16} /> Delete</button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      )}

      {/* 4. Invite Modal Responsive */}
      {isInviteOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-md z-[110] flex items-center justify-center p-3 overflow-y-auto">
          <div className="glass-modal w-full max-w-md my-auto animate-in zoom-in-95 duration-200">
            <div className="flex justify-between items-center p-6 border-b border-border bg-background/50 backdrop-blur-md rounded-t-2xl">
              <h2 className="text-xl font-black uppercase tracking-tighter">Invite Member</h2>
              <button onClick={() => { setIsInviteOpen(false); setInviteLink(''); }} className="p-2 hover:bg-muted rounded-full transition-colors"><X size={24} /></button>
            </div>

            {!inviteLink ? (
              <form onSubmit={handleInvite} className="p-6 space-y-6">
                <div className="space-y-1.5">
                  <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Email Address *</label>
                  <input required type="email" className="glass-input w-full" value={inviteEmail} onChange={e => setInviteEmail(e.target.value)} placeholder="name@company.com" />
                </div>
                <div className="space-y-1.5">
                  <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Base Role</label>
                  <select className="glass-input w-full bg-background" value={inviteRole} onChange={e => setInviteRole(e.target.value)}>
                    <option value="Admin">Admin (Full Access)</option>
                    <option value="Member">Member (Granular)</option>
                  </select>
                </div>
                <div className="flex flex-col sm:flex-row justify-end gap-3 pt-4">
                  <button type="button" onClick={() => setIsInviteOpen(false)} className="btn-secondary py-3 text-xs font-bold uppercase order-2 sm:order-1">Cancel</button>
                  <button type="submit" className="btn-primary py-3 text-xs font-bold uppercase order-1 sm:order-2">Generate Link</button>
                </div>
              </form>
            ) : (
              <div className="p-8 space-y-6 text-center animate-in slide-in-from-bottom-2">
                <div className="w-16 h-16 bg-emerald-500/10 text-emerald-500 rounded-full flex items-center justify-center mx-auto"><CheckCircle2 size={32} /></div>
                <div className="space-y-2">
                  <h3 className="text-xl font-black uppercase tracking-tighter">Link Ready</h3>
                  <p className="text-sm text-zinc-500">Share this link with your teammate to grant access.</p>
                </div>
                <div className="p-4 bg-muted/50 rounded-2xl border border-border/50 break-all text-xs font-mono text-zinc-600 text-left relative group">
                  {inviteLink}
                </div>
                <button
                  onClick={() => {
                    navigator.clipboard.writeText(inviteLink);
                    toast.success("Link copied!");
                  }}
                  className="btn-primary w-full py-4 rounded-2xl flex items-center justify-center gap-2 font-black uppercase tracking-widest text-xs"
                >
                  <Copy size={16} /> Copy to Clipboard
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* 5. Permission Modal Responsive */}
      {isPermOpen && editingMember && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-md z-[110] flex items-center justify-center p-3 overflow-y-auto">
          <div className="glass-modal w-full max-w-lg my-auto animate-in zoom-in-95 duration-200">
            <div className="flex justify-between items-center p-6 border-b border-border bg-background/50 backdrop-blur-md rounded-t-2xl">
              <div>
                <h2 className="text-xl font-black uppercase tracking-tighter">Edit Access</h2>
                <p className="text-[10px] font-black uppercase text-zinc-500 tracking-widest mt-1">For {editingMember.user.name}</p>
              </div>
              <button onClick={() => setIsPermOpen(false)} className="p-2 hover:bg-muted rounded-full transition-colors"><X size={24} /></button>
            </div>
            <form onSubmit={savePermissions} className="p-6 space-y-6">

              <div className="space-y-1.5">
                <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Account Type</label>
                <select className="glass-input w-full bg-background" value={selectedRole} onChange={e => setSelectedRole(e.target.value)}>
                  <option value="Admin">Administrator (Master)</option>
                  <option value="Member">Standard User (Granular)</option>
                </select>
              </div>

              {selectedRole === 'Member' && (
                <div className="space-y-4">
                  <label className="text-[10px] font-black uppercase tracking-widest text-zinc-500">Allowed Actions</label>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-muted/20 p-4 rounded-2xl border border-border/30">
                    {AVAILABLE_PERMISSIONS.map(perm => (
                      <label key={perm.id} className="flex items-center gap-3 cursor-pointer group p-2 rounded-xl hover:bg-background/50 transition-colors">
                        <div className={cn(
                          "w-5 h-5 rounded-lg border-2 flex items-center justify-center transition-all",
                          selectedPerms.includes(perm.id) ? "bg-primary border-primary" : "bg-background border-border group-hover:border-primary"
                        )}>
                          {selectedPerms.includes(perm.id) && <CheckCircle2 size={12} className="text-primary-foreground" />}
                        </div>
                        <input type="checkbox" className="hidden" checked={selectedPerms.includes(perm.id)} onChange={() => togglePermission(perm.id)} />
                        <span className="text-xs font-bold text-zinc-600 dark:text-zinc-400 group-hover:text-zinc-900 transition-colors">{perm.label}</span>
                      </label>
                    ))}
                  </div>
                </div>
              )}

              <div className="flex flex-col sm:flex-row justify-end gap-3 pt-4 border-t border-border/30">
                <button type="button" onClick={() => setIsPermOpen(false)} className="btn-secondary py-3 text-xs font-bold uppercase">Cancel</button>
                <button type="submit" className="btn-primary py-3 text-xs font-bold uppercase">Update Permissions</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}