def rubocop
  container_bash_exec('rails', 'rubocop --require rubocop-rails')
end

def rubocop_fix
  container_bash_exec('rails', 'rubocop --require rubocop-rails -A')
end
