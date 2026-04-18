"use client"

import * as React from "react"
import { Moon, Sun } from "lucide-react"
import { useTheme } from "next-themes"

export function ThemeToggle() {
  const { theme, setTheme, resolvedTheme } = useTheme()
  const [mounted, setMounted] = React.useState(false)

  React.useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return <div className="w-9 h-9 border border-transparent" />
  }

  const isDark = resolvedTheme === "dark"

  return (
    <button
      onClick={() => setTheme(isDark ? "light" : "dark")}
      className="p-2 rounded-xl border border-gray-200 dark:border-white/10 bg-white/50 dark:bg-white/5 hover:bg-white dark:hover:bg-white/10 transition-colors flex items-center justify-center group cursor-pointer"
      aria-label="Toggle theme"
    >
      {isDark ? (
         <Sun className="h-5 w-5 text-gray-400 group-hover:text-amber-400 transition-colors" />
      ) : (
         <Moon className="h-5 w-5 text-gray-400 group-hover:text-primary transition-colors" />
      )}
    </button>
  )
}
