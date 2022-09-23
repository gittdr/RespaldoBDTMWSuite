SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[tmw_showtrace]					
AS
/**
 * 
 * NAME: 
 * tmw_showtrace
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure list all profiler traces that are currently running
 *
 * RETURNS:
 * N/A 
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * None
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 11/10/2006.01 PTS35119 - JGUO initial
 *
 **/

SELECT traceid, 
case property 
when 1 then 'Trace Options'
when 2 then 'FileName'
when 3 then 'MaxSize'
when 4 then 'StopTime'
when 5 then 'Current Trace status'
end, 
value FROM :: fn_trace_getinfo(default) 

GO
GRANT EXECUTE ON  [dbo].[tmw_showtrace] TO [public]
GO
