def fibs(number)
  fib = []
  for i in 0...number
    if i == 0
      fib << 0
    elsif i == 1
      fib << 1
    else
      fib << fib[i-1] + fib[i-2]
    end
  end
  fib
end

def fibs_rec(number)
  if number == 0
    []
  elsif number == 1
    fibs_rec(0) << 0
  elsif number == 2
    fibs_rec(1) << 1
  else
    fib = fibs_rec(number - 1)
    fib << fib[-2] + fib[-1]
  end
end

puts "Enter number:"
number = gets.chomp.to_i
puts fibs_rec(number)
