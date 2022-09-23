SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create PROC [dbo].[d_loadrouteid_for_ddw] @p_route varchar(30) , @p_number int AS  
/**  
 *   
 * NAME:  
 * dbo.D_LOADROUTEID_IBM_SP  
 *  
 * TYPE:  
 * StoredProcedure  
 *  
 * DESCRIPTION:  
 * Returns a list of currently defined routes for instant best match  
 *  
 * RETURNS:  
 * NONE  
 *  
 * RESULT SETS:   
 * none.  
 *  
 * PARAMETERS:  
 * 001 - @p_route varchar(30) first X characters of a route header name  
 * 002 - @p_number int  the number of rows to return  
 *  
 * REFERENCES: (called by and calling references only, don't   
 *              include table/view/object references)  
   
  
 *   
 * REVISION HISTORY:  
 * 10/10/2006.01 ? PTS33644 - DPETE ? Created  
 *  
 **/  
DECLARE  @match_rows int  
  
if @p_number = 1   
 set rowcount 1   
else if @p_number <= 8   
 set rowcount 8  
else if @p_number <= 16  
 set rowcount 16  
else if @p_number <= 24  
 set rowcount 24  
else  
 set rowcount 8  
  
  
  
  
if not exists(SELECT 1 FROM routeheader WHERE rth_name LIKE @p_route + '%')  
   select 'UNKNOWN',0,'UNKNOWN'  
    
else   
   select name = rth_name,   /* naeed name and code field for IMB this is name */  
          code = rth_id, /*left(rth_name,50)*/  /* need alpha for tariff matchvalue, this is code */ 
          alpha_code = convert(varchar(15),rth_id )
   from routeheader  
   where rth_name LIKE @p_route + '%'  
  
set rowcount 0 
GO
GRANT EXECUTE ON  [dbo].[d_loadrouteid_for_ddw] TO [public]
GO
