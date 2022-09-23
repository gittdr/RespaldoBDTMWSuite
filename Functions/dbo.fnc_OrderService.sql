SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[fnc_OrderService]
 (@ord_hdrnumber int)
 
returns varchar(max)


as

begin

 declare @Service as varchar(max)
 
 set @Service = ''
 
 select @Service = @Service + s.svc_description + ', '
   from order_services os inner join [services] s on os.svc_code = s.svc_code
   where os.ord_hdrnumber = @ord_hdrnumber
   
 if LEN(@Service) > 1 
  set @Service = substring(@Service,1,len(@Service)-1)
  
 return @Service
 
end
GO
GRANT EXECUTE ON  [dbo].[fnc_OrderService] TO [public]
GO
