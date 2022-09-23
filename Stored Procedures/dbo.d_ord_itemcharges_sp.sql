SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ord_itemcharges_sp] (	@numberparm	int)
AS
/**
 * 
 * NAME:
 * dbo.d_ord_itemcharges_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

create table #temp_inv (cht_itemcode varchar(6),
			cht_description varchar(30),
			ivd_charge money,
			ord_totalmiles int,
			ord_quantity float,
			ord_unit   varchar(6))
insert #temp_inv
select o.cht_itemcode,
       cht_description,
       	o.ord_charge,		
        o.ord_totalmiles,
        o.ord_quantity,
	o.ord_unit     
from   orderheader o,  chargetype 
where  o.ord_hdrnumber = @numberparm and
       chargetype.cht_itemcode = o.cht_itemcode 

update #temp_inv
set    ord_quantity = 0
where  upper(ord_unit) <> 'MIL'  

update #temp_inv
set ivd_charge = (select sum(i.ivd_charge)
		  from   orderheader,invoicedetail i,chargetype c
		  where  i.ord_hdrnumber = orderheader.ord_hdrnumber and
                         c.cht_itemcode = i.cht_itemcode and
                         c.cht_basis = 'shp' and
                         orderheader.ord_hdrnumber = @numberparm )
where ivd_charge = 0 or ivd_charge is null

insert #temp_inv
select 	i.cht_itemcode,
	c.cht_description,
        i.ivd_charge,
	0,
	0,
        ''
from   orderheader,invoicedetail i,chargetype c
where i.ord_hdrnumber = orderheader.ord_hdrnumber and
      c.cht_itemcode = i.cht_itemcode and
      c.cht_basis = 'ACC' and
      orderheader.ord_hdrnumber = @numberparm
		         
select * 
from #temp_inv


GO
GRANT EXECUTE ON  [dbo].[d_ord_itemcharges_sp] TO [public]
GO
