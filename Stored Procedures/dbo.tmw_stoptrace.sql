SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[tmw_stoptrace] (@trace_id int)				
AS
/**
 * 
 * NAME: 
 * tmw_stoptrace 
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure will stop a trace specified by the trace_id parameter. use tmw_showtrace to get the trace_id
 *
 * RETURNS:
 * N/A 
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * 001 - @trace_id,  int, 
 *       This parameter specifies the trace_id to be killed.
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 11/10/2006.01 PTS35119 - JGUO initial
 *
 **/

exec sp_trace_setstatus @trace_id, 0   --stop
exec sp_trace_setstatus @trace_id, 2   --close and delete

GO
GRANT EXECUTE ON  [dbo].[tmw_stoptrace] TO [public]
GO
