SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template119_refsubreport] (@ord_hdrnumber int)
AS
/*
*
* 
* NAME:invoice_template119_refsubreport
* dbo.invoice_template119_refsubreport
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
* 06/04/07 PTS 36875 - OS - Created
*/

create table #temp (ref_type varchar(6),
                    ref_number varchar(30),
                    ref_sequence int)
                      
insert into #temp 
select	ref_type,
		ref_number,
		ref_sequence   
from referencenumber
where ref_table = 'orderheader'
and ord_hdrnumber = @ord_hdrnumber

order by ref_sequence

select top 10 * from #temp 

GO
GRANT EXECUTE ON  [dbo].[invoice_template119_refsubreport] TO [public]
GO
