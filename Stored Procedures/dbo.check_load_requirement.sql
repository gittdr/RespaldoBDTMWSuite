SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.check_load_requirement    Script Date: 6/1/99 11:54:42 AM ******/
create proc [dbo].[check_load_requirement] 
@lghnum int , @drv varchar(8) , @trc varchar(8) , @trl varchar(8) 
as



declare @ordnum int , @cnt int , @manditory char(1) , @errnum int , @errtext varchar(255)

select @errnum = 0
select @cnt = 0 

select @ordnum = 0 
while ( 
select count(*) 
from stops 
where lgh_number = @lghnum and ord_hdrnumber > @ordnum 
) > 0 begin 

select @ordnum = min ( ord_hdrnumber )
from stops 
where lgh_number = @lghnum and ord_hdrnumber > @ordnum 

if ( select count(*) from loadrequirement where ord_hdrnumber = @ordnum ) > 0 begin 



if ( select count(*) from driverqualifications where drq_driver = @drv ) > 0 begin 

select @cnt = count(*) , @manditory = max ( lrq_manditory )
from loadrequirement 
where ( ord_hdrnumber = @ordnum ) and 
( lrq_equip_type = 'DRV' ) and 
( 
( 
( lrq_not = 'N' ) and
( lrq_type not in ( 
select drq_type
from driverqualifications
where drq_driver = @drv 
) 
) 
) or 
( 
( lrq_not = 'Y' ) and
( lrq_type in ( 
select drq_type
from driverqualifications
where drq_driver = @drv 
) 
) 
) 
) 

end else begin                     

select @cnt = count(*) , @manditory = max ( lrq_manditory )
from loadrequirement 
where ( ord_hdrnumber = @ordnum ) and 
( lrq_not = 'N' ) and
( lrq_equip_type = 'DRV' ) 

end 

if @cnt > 0 begin
if @manditory = 'Y' 
select @errnum = 50002
else if @errnum = 0 
select @errnum = 50001
end

if @errnum = 50002 begin
select @errtext = 'Manditory load requirement not met.'
raiserror @errnum @errtext 
return 
end



if ( select count(*) from tractoraccesories where tca_tractor = @trc ) > 0 begin 

select @cnt = count(*) , @manditory = max ( lrq_manditory )
from loadrequirement 
where ( ord_hdrnumber = @ordnum ) and 
( lrq_equip_type = 'TRC' ) and 
( 
( 
( lrq_not = 'N' ) and
( lrq_type not in ( 
select tca_type 
from tractoraccesories 
where tca_tractor = @trc 
) 
) 
) or 
( 
( lrq_not = 'Y' ) and
( lrq_type in ( 
select tca_type
from tractoraccesories 
where tca_tractor = @trc 
) 
) 
) 
) 

end else begin                     

select @cnt = count(*) , @manditory = max ( lrq_manditory )
from loadrequirement 
where ( ord_hdrnumber = @ordnum ) and 
( lrq_not = 'N' ) and
( lrq_equip_type = 'TRC' ) 

end 

if @cnt > 0 begin
if @manditory = 'Y' 
select @errnum = 50002
else if @errnum = 0 
select @errnum = 50001
end

if @errnum = 50002 begin
select @errtext = 'Manditory load requirement not met.'
raiserror @errnum @errtext 
return 
end



if ( select count(*) from trlaccessories where ta_trailer = @trl ) > 0 begin 

select @cnt = count(*) , @manditory = max ( lrq_manditory )
from loadrequirement, trlaccessories
where ( ord_hdrnumber = @ordnum ) and 
( lrq_equip_type = 'TRL' ) and 
(( ta_quantity < lrq_quantity and ta_trailer = @trl and ta_type = lrq_type ) OR

( 
( 
( lrq_not = 'N' ) and
( lrq_type not in ( 
select ta_type 
from trlaccessories 
where ta_trailer = @trl 
) 
) 
)) or 
( 
( lrq_not = 'Y' ) and
( lrq_type in ( 
select ta_type
from trlaccessories 
where ta_trailer = @trl 
) 
) 
) 
) 

end else begin                     

select @cnt = count(*) , @manditory = max ( lrq_manditory )
from loadrequirement 
where ( ord_hdrnumber = @ordnum ) and 
( lrq_not = 'N' ) and
( lrq_equip_type = 'TRL' ) 

end 

if @cnt > 0 begin
if @manditory = 'Y' 
select @errnum = 50002
else if @errnum = 0 
select @errnum = 50001
end

if @errnum = 50002 begin
select @errtext = 'Manditory load requirement not met.'
raiserror @errnum @errtext 
return 
end

if @errnum = 50001 begin
select @errtext = 'Non-manditory load requirement not met.'
raiserror @errnum @errtext 
return 
end

end            

end           








GO
GRANT EXECUTE ON  [dbo].[check_load_requirement] TO [public]
GO
