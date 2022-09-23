SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadtrpid_sp] @cmp_id varchar(8) , @number int AS 
/**
 * 
 * NAME:
 * dbo.d_loadtrpid_sp 
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


if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT cmp_id FROM edi_trading_partner WHERE cmp_id LIKE @cmp_id + '%' ) 
	 SELECT edi_trading_partner.cmp_id,   
         	edi_trading_partner.trp_id,   
         	edi_trading_partner.trp_210ID,   
         	edi_trading_partner.trp_status,   
         	edi_trading_partner.trp_alias,
                company.cmp_name 
    	  FROM  edi_trading_partner,company
	  WHERE edi_trading_partner.cmp_id LIKE @cmp_id + '%' 
		and company.cmp_id = edi_trading_partner.cmp_id
	ORDER BY edi_trading_partner.cmp_id 
else 
	SELECT edi_trading_partner.cmp_id,   
         	edi_trading_partner.trp_id,   
         	edi_trading_partner.trp_210ID,   
         	edi_trading_partner.trp_status,   
         	edi_trading_partner.trp_alias,
		'' 
    	  FROM  edi_trading_partner
	  WHERE cmp_id = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadtrpid_sp] TO [public]
GO
