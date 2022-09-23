SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [dbo].[fnc_Carriers]
 (@ord_hdrnumber int) 
 returns varchar(1000)
as

begin

 declare @Carriers varchar(1000)
 Declare @tbl Table (Carriers varchar(1000), ID int)

 insert into @tbl (Carriers, ID)
 Select movement_type + ': ' + carrier + ' $' + Cast(amount as varchar(20)), 1 
 from ordercarrier WITH (NOLOCK)
 where ord_hdrnumber =@ord_hdrnumber
 
 select  @Carriers = MAX(STUFF(t2.ID,1,1,''))  
 FROM @tbl t1  
 CROSS apply(  
 SELECT ', ' + t2.Carriers  
 FROM @tbl t2  
 WHERE t2.ID = t1.ID AND t2.Carriers > ''  
 FOR XML PATH('')  
 ) AS t2 (ID)  
 GROUP BY  
 t1.id  
 
  
 --Calculate total as well------
 declare @total money
 
 select @total = 
 (
  select sum(amount) as total
  from ordercarrier WITH (NOLOCK)
  where ord_hdrnumber =@ord_hdrnumber  
 )
 
 return  LTRIM(RTRIM(@Carriers))  + ' (Total: $' + Cast(@total as varchar(20)) + ')'
 
end
GO
GRANT EXECUTE ON  [dbo].[fnc_Carriers] TO [public]
GO
