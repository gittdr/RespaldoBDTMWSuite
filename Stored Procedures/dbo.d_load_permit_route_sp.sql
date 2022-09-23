SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_permit_route_sp] @ps_name varchar(50), @pia int, @number int AS

/**
 * 
 * NAME:
 * dbo.d_load_permit_route_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure drives instant best match columns for permit routes
 *
 * RETURNS:
 * Instant-Best Match for Permit Routes
 *
 * PARAMETERS:
 * 001 - @ps_name, varchar(50)
 *       This parameter indicates the name of the route you are looking for
 * 002 - @p_note_type, int
 *       This parameter indicates the Issuing Authority of the route you are looking for
 * 003 - @pi_number, int, int
         This paramater is the number of rows to return
 * REVISION HISTORY:
 * 02/23/2007 ? PTS33381 - Jason Bauwin ? Original release
 *
 **/


DECLARE @match_rows int

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

if exists(SELECT prt_name FROM permit_route WHERE prt_name LIKE @ps_name + '%' AND pia_id = @pia) 
   select @match_rows = 1
else
   select @match_rows = 0
if @match_rows = 1
   select prt_name,
          prt_id
     from permit_route
     where pia_id = @pia
       and prt_name like @ps_name + '%'
    order by prt_name
else
   select prt_name,
          prt_id
     from permit_route
    where prt_name = 'UNKNOWN'
    order by prt_name

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_load_permit_route_sp] TO [public]
GO
