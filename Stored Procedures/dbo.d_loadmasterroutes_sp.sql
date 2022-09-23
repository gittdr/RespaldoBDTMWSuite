SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadmasterroutes_sp] @route varchar(30) , @number int AS 

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

if exists ( SELECT mr_name FROM master_routes WHERE mr_name LIKE @route + '%' and mr_sequence = 1 ) 
	SELECT mr_name , 
	       mov_number, 
          stp_number, 
          mr_sequence, 
          mr_arrival,
          mr_departure,
			mr_earliest,
			mr_latest
		FROM master_routes
		WHERE mr_name LIKE @route + '%' and mr_sequence = 1
	ORDER BY mr_name 
else 
	SELECT mr_name , 
          mov_number, 
          stp_number, 
          mr_sequence, 
          mr_arrival,
          mr_departure,
			mr_earliest,
			mr_latest
		FROM master_routes
		WHERE mr_name = 'UNKNOWN' 

set rowcount 0 


GO
GRANT EXECUTE ON  [dbo].[d_loadmasterroutes_sp] TO [public]
GO
