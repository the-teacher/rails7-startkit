def tailwind_start
  container_bash_exec('rails', 'bin/rails tailwindcss:watch', detached = true)
end

def tailwind_stop
  container_bash_exec('rails', 'pkill -9 -f tailwindcss', detached = true)
end
