SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[tmw_runtrace_bylogin] (@trace_file_folder varchar(1000) = 'c:\temp',
			@trace_runtime_in_min int = 120,
			@trace_filter_duration_in_ms int = 0,
			@trace_filter_login varchar(50) = '',
			@trace_level int = 1)

AS
/**
 * 
 * NAME: 
 * tmw_runtrace_bylogin
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Start a profiler trace in the background with a login filter. use "tmw_showtrace" to check which trace is running.
 * The trace name will be prefixed with "tmw_trace". This proc can be used for unattended performance
 * monitoring and benchmarking. It can be scheduled as an agent job or run manually. For benchmark,
 * start the trace at the same time slot for comparison.
 *
 * RETURNS:
 * N/A 
 *
 * RESULT SETS: 
 * None
 *
 * PARAMETERS:
 * 001 - @trace_file_folder,  varchar(1000), default = 'c:\temp', 
 *       This parameter can be local path or UNC path. Trace file name will be automatically generated.
 * 002 - @trace_runtime_in_min, int, default = 120
 *       This parameter specifies how long the trace will run (in minutes) 
 * 003 - @trace_filter_duration_in_ms, int, default = 500
 *       This parameter specify the trace duration filter value in milli seconds. 
 * 004 - @trace_filter_login varchar(5)
 *       This is the login name
 * 005 - @trace_level, int, default = 1
 *       This parameter indicates how detail the trace will be: 
 *		1 - basic trace, 
 *		2 - plus error and warning
 *		3 - plus starting event
 *		4 - plus excution plan
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 11/10/2006.01 - PTS35119 - JGUO - initial version
 * 01/21/2010     - MDH - Changed to check for SQL Server 2000 instead of 2005.
 *
 **/

-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
declare @stop datetime
declare @tracefilename nvarchar(128)
set @maxfilesize = 100 --in MBytes, will auto split when exceeding 100M

-----------------------------------------
--replace duration, server and share name
-----------------------------------------
set @stop = dateadd(mi, @trace_runtime_in_min, getdate())

if right(@trace_file_folder, 1) = '\'
begin
	set @tracefilename = @trace_file_folder + 'tmw_trace_'
end
else
begin
	set @tracefilename = @trace_file_folder + '\tmw_trace_'
end

set @tracefilename = @tracefilename + replace(@@SERVERNAME,'\','_') + '$' + replace((replace(rtrim(convert(varchar(50), getdate(), 100)), ':','_')), ' ', '-')

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share


exec @rc = sp_trace_create @TraceID output, 0, @tracefilename, @maxfilesize, @stop 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1


if @trace_level  >= 1
begin

--RPC:Completed
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 14, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 10, 21, @on
exec sp_trace_setevent @TraceID, 10, 22, @on
exec sp_trace_setevent @TraceID, 10, 34, @on

--SQL:BatchCompleted
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 13, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 21, @on
exec sp_trace_setevent @TraceID, 12, 22, @on
exec sp_trace_setevent @TraceID, 12, 34, @on

--SP:Completed
exec sp_trace_setevent @TraceID, 43, 1, @on
exec sp_trace_setevent @TraceID, 43, 3, @on
exec sp_trace_setevent @TraceID, 43, 6, @on
exec sp_trace_setevent @TraceID, 43, 9, @on
exec sp_trace_setevent @TraceID, 43, 10, @on
exec sp_trace_setevent @TraceID, 43, 11, @on
exec sp_trace_setevent @TraceID, 43, 12, @on
exec sp_trace_setevent @TraceID, 43, 13, @on
exec sp_trace_setevent @TraceID, 43, 14, @on
exec sp_trace_setevent @TraceID, 43, 16, @on
exec sp_trace_setevent @TraceID, 43, 17, @on
exec sp_trace_setevent @TraceID, 43, 18, @on
exec sp_trace_setevent @TraceID, 43, 21, @on
exec sp_trace_setevent @TraceID, 43, 22, @on
exec sp_trace_setevent @TraceID, 43, 34, @on

--SP:StmtCompleted
exec sp_trace_setevent @TraceID, 45, 1, @on
exec sp_trace_setevent @TraceID, 45, 3, @on
exec sp_trace_setevent @TraceID, 45, 6, @on
exec sp_trace_setevent @TraceID, 45, 9, @on
exec sp_trace_setevent @TraceID, 45, 10, @on
exec sp_trace_setevent @TraceID, 45, 11, @on
exec sp_trace_setevent @TraceID, 45, 12, @on
exec sp_trace_setevent @TraceID, 45, 13, @on
exec sp_trace_setevent @TraceID, 45, 14, @on
exec sp_trace_setevent @TraceID, 45, 16, @on
exec sp_trace_setevent @TraceID, 45, 17, @on
exec sp_trace_setevent @TraceID, 45, 18, @on
exec sp_trace_setevent @TraceID, 45, 21, @on
exec sp_trace_setevent @TraceID, 45, 22, @on
exec sp_trace_setevent @TraceID, 45, 34, @on

--ExistingConnection
exec sp_trace_setevent @TraceID, 17, 1, @on
exec sp_trace_setevent @TraceID, 17, 3, @on
exec sp_trace_setevent @TraceID, 17, 6, @on
exec sp_trace_setevent @TraceID, 17, 9, @on
exec sp_trace_setevent @TraceID, 17, 10, @on
exec sp_trace_setevent @TraceID, 17, 11, @on
exec sp_trace_setevent @TraceID, 17, 12, @on
exec sp_trace_setevent @TraceID, 17, 13, @on
exec sp_trace_setevent @TraceID, 17, 14, @on
exec sp_trace_setevent @TraceID, 17, 16, @on
exec sp_trace_setevent @TraceID, 17, 17, @on
exec sp_trace_setevent @TraceID, 17, 18, @on
exec sp_trace_setevent @TraceID, 17, 21, @on
exec sp_trace_setevent @TraceID, 17, 22, @on
exec sp_trace_setevent @TraceID, 17, 34, @on

end

if @trace_level >= 2
begin

--Attention
exec sp_trace_setevent @TraceID, 16, 1, @on
exec sp_trace_setevent @TraceID, 16, 3, @on
exec sp_trace_setevent @TraceID, 16, 6, @on
exec sp_trace_setevent @TraceID, 16, 9, @on
exec sp_trace_setevent @TraceID, 16, 10, @on
exec sp_trace_setevent @TraceID, 16, 11, @on
exec sp_trace_setevent @TraceID, 16, 12, @on
exec sp_trace_setevent @TraceID, 16, 13, @on
exec sp_trace_setevent @TraceID, 16, 14, @on
exec sp_trace_setevent @TraceID, 16, 16, @on
exec sp_trace_setevent @TraceID, 16, 17, @on
exec sp_trace_setevent @TraceID, 16, 18, @on
exec sp_trace_setevent @TraceID, 16, 21, @on
exec sp_trace_setevent @TraceID, 16, 22, @on
exec sp_trace_setevent @TraceID, 16, 34, @on

end

if @trace_level >= 3
begin

--starting event and sql:stmtcompleted event

--RPC:Starting
exec sp_trace_setevent @TraceID, 11, 1, @on
exec sp_trace_setevent @TraceID, 11, 3, @on
exec sp_trace_setevent @TraceID, 11, 6, @on
exec sp_trace_setevent @TraceID, 11, 9, @on
exec sp_trace_setevent @TraceID, 11, 10, @on
exec sp_trace_setevent @TraceID, 11, 11, @on
exec sp_trace_setevent @TraceID, 11, 12, @on
exec sp_trace_setevent @TraceID, 11, 13, @on
exec sp_trace_setevent @TraceID, 11, 14, @on
exec sp_trace_setevent @TraceID, 11, 16, @on
exec sp_trace_setevent @TraceID, 11, 17, @on
exec sp_trace_setevent @TraceID, 11, 18, @on
exec sp_trace_setevent @TraceID, 11, 21, @on
exec sp_trace_setevent @TraceID, 11, 22, @on
exec sp_trace_setevent @TraceID, 11, 34, @on

--SQL:StmtStarting
exec sp_trace_setevent @TraceID, 40, 1, @on
exec sp_trace_setevent @TraceID, 40, 3, @on
exec sp_trace_setevent @TraceID, 40, 6, @on
exec sp_trace_setevent @TraceID, 40, 9, @on
exec sp_trace_setevent @TraceID, 40, 10, @on
exec sp_trace_setevent @TraceID, 40, 11, @on
exec sp_trace_setevent @TraceID, 40, 12, @on
exec sp_trace_setevent @TraceID, 40, 13, @on
exec sp_trace_setevent @TraceID, 40, 14, @on
exec sp_trace_setevent @TraceID, 40, 16, @on
exec sp_trace_setevent @TraceID, 40, 17, @on
exec sp_trace_setevent @TraceID, 40, 18, @on
exec sp_trace_setevent @TraceID, 40, 21, @on
exec sp_trace_setevent @TraceID, 40, 22, @on
exec sp_trace_setevent @TraceID, 40, 34, @on

--SQL:StmtCompleted
exec sp_trace_setevent @TraceID, 41, 1, @on
exec sp_trace_setevent @TraceID, 41, 3, @on
exec sp_trace_setevent @TraceID, 41, 6, @on
exec sp_trace_setevent @TraceID, 41, 9, @on
exec sp_trace_setevent @TraceID, 41, 10, @on
exec sp_trace_setevent @TraceID, 41, 11, @on
exec sp_trace_setevent @TraceID, 41, 12, @on
exec sp_trace_setevent @TraceID, 41, 13, @on
exec sp_trace_setevent @TraceID, 41, 14, @on
exec sp_trace_setevent @TraceID, 41, 16, @on
exec sp_trace_setevent @TraceID, 41, 17, @on
exec sp_trace_setevent @TraceID, 41, 18, @on
exec sp_trace_setevent @TraceID, 41, 21, @on
exec sp_trace_setevent @TraceID, 41, 22, @on
exec sp_trace_setevent @TraceID, 41, 34, @on

--SQL:BatchStarting
exec sp_trace_setevent @TraceID, 13, 1, @on
exec sp_trace_setevent @TraceID, 13, 3, @on
exec sp_trace_setevent @TraceID, 13, 6, @on
exec sp_trace_setevent @TraceID, 13, 9, @on
exec sp_trace_setevent @TraceID, 13, 10, @on
exec sp_trace_setevent @TraceID, 13, 11, @on
exec sp_trace_setevent @TraceID, 13, 12, @on
exec sp_trace_setevent @TraceID, 13, 13, @on
exec sp_trace_setevent @TraceID, 13, 14, @on
exec sp_trace_setevent @TraceID, 13, 16, @on
exec sp_trace_setevent @TraceID, 13, 17, @on
exec sp_trace_setevent @TraceID, 13, 18, @on
exec sp_trace_setevent @TraceID, 13, 21, @on
exec sp_trace_setevent @TraceID, 13, 22, @on
exec sp_trace_setevent @TraceID, 13, 34, @on

--SP:Starting
exec sp_trace_setevent @TraceID, 42, 1, @on
exec sp_trace_setevent @TraceID, 42, 3, @on
exec sp_trace_setevent @TraceID, 42, 6, @on
exec sp_trace_setevent @TraceID, 42, 9, @on
exec sp_trace_setevent @TraceID, 42, 10, @on
exec sp_trace_setevent @TraceID, 42, 11, @on
exec sp_trace_setevent @TraceID, 42, 12, @on
exec sp_trace_setevent @TraceID, 42, 13, @on
exec sp_trace_setevent @TraceID, 42, 14, @on
exec sp_trace_setevent @TraceID, 42, 16, @on
exec sp_trace_setevent @TraceID, 42, 17, @on
exec sp_trace_setevent @TraceID, 42, 18, @on
exec sp_trace_setevent @TraceID, 42, 21, @on
exec sp_trace_setevent @TraceID, 42, 22, @on
exec sp_trace_setevent @TraceID, 42, 34, @on

--SP:StmtStarting
exec sp_trace_setevent @TraceID, 44, 1, @on
exec sp_trace_setevent @TraceID, 44, 3, @on
exec sp_trace_setevent @TraceID, 44, 6, @on
exec sp_trace_setevent @TraceID, 44, 9, @on
exec sp_trace_setevent @TraceID, 44, 10, @on
exec sp_trace_setevent @TraceID, 44, 11, @on
exec sp_trace_setevent @TraceID, 44, 12, @on
exec sp_trace_setevent @TraceID, 44, 13, @on
exec sp_trace_setevent @TraceID, 44, 14, @on
exec sp_trace_setevent @TraceID, 44, 16, @on
exec sp_trace_setevent @TraceID, 44, 17, @on
exec sp_trace_setevent @TraceID, 44, 18, @on
exec sp_trace_setevent @TraceID, 44, 21, @on
exec sp_trace_setevent @TraceID, 44, 22, @on
exec sp_trace_setevent @TraceID, 44, 34, @on

end

if @trace_level >= 4
begin

--Execution Plan
exec sp_trace_setevent @TraceID, 68, 1, @on
exec sp_trace_setevent @TraceID, 68, 3, @on
exec sp_trace_setevent @TraceID, 68, 6, @on
exec sp_trace_setevent @TraceID, 68, 9, @on
exec sp_trace_setevent @TraceID, 68, 10, @on
exec sp_trace_setevent @TraceID, 68, 11, @on
exec sp_trace_setevent @TraceID, 68, 12, @on
exec sp_trace_setevent @TraceID, 68, 13, @on
exec sp_trace_setevent @TraceID, 68, 14, @on
exec sp_trace_setevent @TraceID, 68, 16, @on
exec sp_trace_setevent @TraceID, 68, 17, @on
exec sp_trace_setevent @TraceID, 68, 18, @on
exec sp_trace_setevent @TraceID, 68, 21, @on
exec sp_trace_setevent @TraceID, 68, 22, @on
exec sp_trace_setevent @TraceID, 68, 34, @on

end




-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint
declare @loginname nvarchar(50)

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'
set @bigintfilter = @trace_filter_duration_in_ms
set @loginname = @trace_filter_login

If charindex('SQL Server  2000', @@version) = 0 --it is in micro second in sql 2005
begin
	set @bigintfilter = @bigintfilter * 1000
end

exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

exec sp_trace_setfilter @TraceID, 11, 0, 0, @loginname 

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID, @tracefilename + '.trc', 'for performance benchmark', 'started at ' + convert(varchar(40),getdate()), 'will stop at ' + convert(varchar(40), @stop)
goto finish

error: 
select ErrorCode=@rc

finish: 
GO
