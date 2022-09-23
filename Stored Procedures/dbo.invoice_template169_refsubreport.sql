SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template169_refsubreport] (@ord_hdrnumber int, @ivh_hdrnumber int)
AS
/*
*
* 
* NAME:invoice_template169_refsubreport
* dbo.invoice_template169_refsubreport
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Provides a return of ref_type and ref_number
*
*
* RETURNS:
* n/a
*
* RESULT SETS: 
* See Select Below.
*
* PARAMETERS:
* 001 - @ord_hdrnumber, int, input;
*       
* REFERENCES: 
* N/A
* 
* 
* 
* REVISION HISTORY:
* 01/15/10 PTS 50465 - TMEZE - Created from 110
*/

create table #temp (ref_type varchar(6),
                    ref_number varchar(30),
                    ref_sequence int)

if @ord_hdrnumber <> 0
begin 
	insert into #temp 
	select 'ORD#' as ref_type,
		ord_number as ref_number,
		0 as ref_sequence
	from orderheader 
	where ord_hdrnumber = @ord_hdrnumber

	union

	select ref_type,
		ref_number,
		case ref_type
			when 'BL#' then ref_sequence + 1000
			when 'PO#' then ref_sequence + 2000
			else ref_sequence + 3000
		end as ref_sequence
	from referencenumber
	where ref_table = 'orderheader'
	and ord_hdrnumber = @ord_hdrnumber

	order by ref_sequence
end

else
begin
	insert into #temp 
	SELECT referencenumber.ref_type,   
       referencenumber.ref_number,   
       case ref_type
			when 'BL#' then ref_sequence + 1000
			when 'PO#' then ref_sequence + 2000
			else ref_sequence + 3000
		end as ref_sequence
	FROM referencenumber join invoiceheader on referencenumber.ref_tablekey = invoiceheader.ivh_hdrnumber 
	WHERE ref_table = 'invoiceheader'
	and invoiceheader.ivh_hdrnumber = @ivh_hdrnumber
	and @ivh_hdrnumber > 0

	order by ref_sequence 
end   

select top 10 * from #temp 

GO
GRANT EXECUTE ON  [dbo].[invoice_template169_refsubreport] TO [public]
GO
