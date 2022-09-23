SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_loadtruckstopid_sp    Script Date: 8/20/97 1:57:58 PM ******/
create procedure [dbo].[d_loadtruckstopid_sp] @comp varchar(8) , @number int AS

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

if exists ( SELECT ts_code FROM truckstops WHERE ts_code >= @comp ) 
	SELECT ts_name , ts_code , ts_city
		FROM truckstops
		WHERE ts_code >= @comp
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
	SELECT 'UNKNOWN', 'UNKNOWN',  'UNKNOWN'

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadtruckstopid_sp] TO [public]
GO
