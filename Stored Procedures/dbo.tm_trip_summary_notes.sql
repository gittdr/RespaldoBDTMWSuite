SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_trip_summary_notes] @ord_number varchar(12),
					    @driver_id varchar(18)
AS

/*
	D - driver
	T - tractor
	R - trailer
	C - company
	CMD - commodity
	DI - delivery instr
	LI - loading instr
*/

(SELECT not_text, not_sequence 
FROM notes (NOLOCK)
WHERE ntb_table='orderheader' and not_type in ('D','T','R','C','CMD','DI','LI') and nre_tablekey=@ord_number

union

SELECT not_text, not_sequence 
FROM notes (NOLOCK)
WHERE ntb_table='manpowerprofile' and nre_tablekey=@driver_id)
ORDER BY not_sequence

GO
GRANT EXECUTE ON  [dbo].[tm_trip_summary_notes] TO [public]
GO
