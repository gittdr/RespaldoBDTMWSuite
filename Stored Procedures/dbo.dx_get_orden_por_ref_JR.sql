SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--
-- Busca en la tabla de order header si existe una orden con ese tipo y numero de referencia
-- @Ref tipo de referencia = 'REF'.
-- @sid = numero de referencia.
-- @ord_startdate =  fecha del viaje.
-- @max_update_status = estatus maximo para hacer el update. 'PLN'
-- @@ord_number Num de orden string
-- @@ord_hdrnumber Num de Orden Entero
-- @@updateflag Bandera que indica la accion.
-- @@updatemsg Mensaje de la situacion de la orden
-- @@ord_status status de la orden actual.


CREATE proc [dbo].[dx_get_orden_por_ref_JR]
	(@ref varchar(6),
	 @sid varchar(30), 
	 @billto varchar(8),
	 @max_update_status varchar(6),
	 @@ord_number varchar(12) OUTPUT, 
	 @@ord_hdrnumber int OUTPUT,
	 @@updateflag char(1) OUTPUT,
	 @@updatemsg varchar(50) OUTPUT,
	 @@ord_status varchar(6) OUTPUT)
as

declare @v_mov int, @v_ordstatus varchar(6), @v_ordinvstatus varchar(6), @v_orddispcode int, 
		@v_maxdispcode int, @v_includecancel varchar(6),@v_ordbookedby varchar(20)

--select @v_includecancel = case isnull(@@updateflag,'') when 'C' then 'CAN' else 'XXX' end

select @ref = NULLIF(@ref,''), @@ord_number = '', @@ord_hdrnumber = 0, @@updateflag = 'N', @@updatemsg = ''

select top 1 @@ord_number = isnull(ord_number,'')
     , @@ord_hdrnumber = isnull(orderheader.ord_hdrnumber,0)
     , @v_mov = isnull(mov_number, 0)
     , @v_ordstatus = isnull(ord_status,'')
     , @v_ordinvstatus = isnull(ord_invoicestatus,'')
     , @v_ordbookedby = isnull(ord_bookedby,'')
  from orderheader
 inner join referencenumber
    on ref_tablekey = orderheader.ord_hdrnumber
   and ref_table = 'orderheader'
 where referencenumber.ref_number = @sid
	and referencenumber.ref_type = ISNULL('REF',referencenumber.ref_type)
	and orderheader.ord_billto	= @billto
   --and ord_status not in (@v_includecancel,'FOR','REF')
    order by orderheader.ord_hdrnumber desc

 
select @@ord_status = isnull(@v_ordstatus,'')

if isnull(@v_mov, 0) = 0
begin
	select top 1 @@ord_number = isnull(ord_number,'')
	     , @@ord_hdrnumber = isnull(orderheader.ord_hdrnumber,0)
	     , @v_mov = isnull(mov_number, 0)
	     , @v_ordstatus = isnull(ord_status,'')
	     , @v_ordinvstatus = isnull(ord_invoicestatus,'')
	  from orderheader
	 inner join referencenumber
	    on ref_tablekey = orderheader.ord_hdrnumber
	   and ref_table = 'orderheader'
	 where referencenumber.ref_number = @sid
	   and referencenumber.ref_type = ISNULL('REF',referencenumber.ref_type)
	   and ord_status not in ('CAN','FOR','REF')
	   	and orderheader.ord_billto	= @billto
	   --and abs(datediff(mm, ord_startdate, @ord_startdate)) < 2
	   and orderheader.ord_editradingpartner is null			--AROSS|NS88103
	 order by orderheader.ord_hdrnumber desc
	
	select @@ord_status = isnull(@v_ordstatus,'')
	
	if isnull(@v_mov, 0) = 0
		select @@updateflag = 'X'
		     , @@updatemsg = 'Active order cannot be found in TMWSuite'
	else

	begin
		--update orderheader
		   --set ord_editradingpartner = @trp_id
		--where ord_number = @@ord_number
		select @@updatemsg = 'Order exists but was not created from LTSL2'
	end

end
else
begin
	if @@ord_status = 'CAN'
	begin
		select @@updateflag = 'Y'
		     , @@updatemsg = 'No. de Orden a sido cancelada'
		return 1
	end
	
	if (select count(1) from orderheader where mov_number = @v_mov) > 1
	begin
		select @@updateflag = 'C'
		     , @@updatemsg = 'No. de Order a sido consolidada con otras ordenes'
		return 1
	end

	if (select count(distinct mov_number) from stops WITH (NOLOCK) WHERE ord_hdrnumber = @@ord_hdrnumber) > 1
	begin
		select @@updateflag = 'C'
		     , @@updatemsg = 'Order has been cross-docked'
		return 1
	end

	if @v_ordbookedby not in('TMWDX','DX','IMPORT')
	begin
		select @@updateflag = 'U'
			  ,@@updatemsg = 'Order exists in TMW and update will be permitted.'
		return 1
	end
			  
	if @v_ordinvstatus = 'PPD'
		select @@updateflag = 'I'
		     , @@updatemsg = 'No. de Order ya esta facturada en TMWSuite'
	else
	begin
		if @v_ordstatus IN ('PLN','DSP')
		begin
			if (select top 1 lgh_outstatus from legheader where ord_hdrnumber = @@ord_hdrnumber order by lgh_number) = 'STD'
				select @v_ordstatus = 'STD'
		end
		select @v_maxdispcode = code
		  from labelfile
		 where labeldefinition = 'DispStatus'
	  	   and abbr = @max_update_status
		select @v_orddispcode = code
		  from labelfile
		 where labeldefinition = 'DispStatus'
		   and abbr = @v_ordstatus
		if @v_maxdispcode < @v_orddispcode
			select @@updatemsg = 'Order is not allowed to be automatically updated'
		else
			select @@updateflag = 'Y'
			     , @@updatemsg = 'Order exists in TMWSuite and can be updated'
	end
end

return 1

GO
