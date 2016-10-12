module HasIgsn
  extend ActiveSupport::Concern
  
  def create_igsn(prefix,stone)
        literals = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'] 	   
        literals.delete('I')
        literals.delete('O')      	  
	literal_to_number=Hash.new
	number_to_literal=Hash.new
	literals.each_index do |idx|
		c=literals[idx]
		literal_to_number[c]=idx
		number_to_literal[idx]=c
        end 
	lastigsnstone=Stone.where("igsn ILIKE ?","#{prefix}%").order(igsn: :desc).first
	
#	logger.info Stone.where("igsn ILIKE ?","#{prefix}#%").order(igsn: :desc).to_sql.inspect
#	lastigsnstone=Stone.where("igsn is not null").order(igsn: :desc).first	

	prefix = user.prefix  
	if (lastigsnstone)
		lastigsn=lastigsnstone.igsn
		lastigsn.sub!(prefix,"")
		igsnnr=to_number(lastigsn,literal_to_number)
		igsnnr=igsnnr+1
	else
		igsnnr=0		  
	end
	igsn=to_igsn(igsnnr,number_to_literal)
	stone.igsn=prefix+igsn.rjust(9-prefix.length,'0')		  
  end

  def to_number (igsn,literal_to_number)
	modulo=literal_to_number.length
	len=igsn.length
	result=0
	len.times do |i| 
		character=igsn[i]
		exponent=len-i-1
		factor=modulo**exponent
		number=literal_to_number[character]
		result=result+(factor*number)
	end
	return result
  end
  
  def to_igsn (number,number_to_literal)
	modulo=number_to_literal.length	  
	quotient=number
	igsn=""	  
	while quotient>0		
		remains = quotient % modulo
		quotient = quotient / modulo			
		c=number_to_literal[remains]
		igsn=c+igsn		
	end
	return igsn
  end

  
end
