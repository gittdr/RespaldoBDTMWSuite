SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_load_detailed_truckstop_id_sp] @p_comp varchar(8) , @p_number int AS

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

if exists ( SELECT ts_code FROM truckstops WHERE ts_code >= @p_comp ) 
	SELECT ts_name, ts_code, ts_address, ts_city, ts_fax_number, ts_email_address
		FROM truckstops
		WHERE ts_code >= @p_comp
		ORDER BY ts_code
else 
/* jude 4/12/97 replaced foll code
	SELECT ts_name , ts_code ,  'UNKNOWN'
		FROM truckstops
		WHERE ts_code = 'UNKNOWN' 
*/
/* jet 9/12/98 for PTS #4386, need to return character for city not int/smallint
	SELECT 'UNKNOWN', 0,  'UNKNOWN'
*/
	SELECT 'UNKNOWN', 'UNKNOWN',  'UNKNOWN', '', '', ''

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_load_detailed_truckstop_id_sp] TO [public]
GO
