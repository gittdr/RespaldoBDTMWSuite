SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*

--sample calls
exec dbo.tmw_runtrace

exec dbo.tmw_runtrace @trace_file_folder = 'c:\temp', 
		@trace_runtime_in_min = 10,
		@trace_filter_duration_in_ms = 0,
		@completed_events = 1,
		@errors_warnings = 0

c:\temp\tmwtrace~XPCURNUTT~2010-01-19-160433~dur-0~1000000.trc
will stop at Jan 19 2010  4:14PM



exec dbo.tmw_runtrace @trace_file_folder = 'c:\temp', 
		@trace_runtime_in_min = 120,
		@trace_filter_duration_in_ms = 5000,
		@completed_events = 0,
		@started_events = 1,
		@errors_warnings = 1,
		@filter_spid = 98

exec dbo.tmw_runtrace @trace_file_folder = 'c:\temp', 
		@trace_runtime_in_min = 120,
		@trace_filter_duration_in_ms = 5000,
		@completed_events = 1,
		@started_events = 1,
		@errors_warnings = 1,
		@filter_spid = 98

exec dbo.tmw_runtrace @trace_file_folder = 'c:\temp', 
		@trace_runtime_in_min = 120,
		@completed_events = 1,
		@showplan_xml = 1,
		@errors_warnings = 0,
		@transaction_info  = 1

--check traces that are running
exec dbo.tmw_showtrace

--stop the trace specified by trace_id
exec dbo.tmw_stoptrace @trace_id = 1

*/

CREATE PROCEDURE [dbo].[tmw_runtrace] (@trace_file_folder varchar(1000) = 'c:\temp',
			@trace_runtime_in_min int = 120,
			@trace_filter_duration_in_ms int = 50,
			@completed_events int = 1,
			@started_events int = 0,
			@errors_warnings int = 1,
			@locking_info int = 0,
			@auto_stats int = 0,
			@transaction_info int = 0,
			@showplan_xml int = 0,
			@filter_spid int = 0,
			@filter_loginname nvarchar(50) = '',
			@filter_application nvarchar(50) = '',
			@filter_hostname nvarchar(100) = '')


AS
/**
 * 
 * NAME: 
 * tmw_runtrace
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Start a profiler trace in the background. use "tmw_showtrace" to check which trace is running.
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
 * 004 - @completed_events, int, default = 1,
 *       This parameter specifies whether or not completed events will be captured
 * 005 - @started_events, int, default = 0,
 *       This parameter specifies whether or not started events will be captured
 * 006 - @errors_warnings, int, default = 1,
 *       This parameter specifies whether or not error and warning events will be captured
 * 007 - @locking_info, int, default = 0,
 *       This parameter specifies whether or not locking information events will be captured
 * 008 - @auto_stats, int, default = 0,
 *       This parameter specifies whether or not auto update stats events will be captured
 * 009 - @transaction_info, int, default = 0,
 *       This parameter specifies whether or not transaction open/close events will be captured
 * 010 - @showplan_xml, int, default = 0,
 *       This parameter specifies whether or not execution plan events will be captured
 * 011 - @filter_spid, int, default = 0,
 *       This parameter specifies whether or not to filter on a specific spid
 * 012 - @filter_loginname, nvarchar(50), default = '',
 *       This parameter specifies whether or not to filter on a specific loginname
 * 013 - @filter_application, nvarchar(50), default = '',
 *       This parameter specifies whether or not to filter on a specific application
 * 
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 11/10/2006.01 - PTS35119 - JGUO - initial version
 * 09/12/2007.01 - jg - handle @@servername null case
 * 09/21/2007.01 - jg - add SQL:stmtrecompile event
 * 10/31/2007.01 - jg - enable file rollover
 * 10/31/2007.01 - jg - print user user-friendly error message
 * 03/05/2008.01 - mc - rearchitecture
 **/

SET NOCOUNT ON
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
declare @stop datetime
declare @tracefilename nvarchar(1000)
declare @tbl_eventclass table(eventclass int) 
declare @eventclass int
declare @tbl_columns table(colid int) 
declare @columns int
declare @on bit

-----------------------------------------
--Declare & Set Columns we will collect for each eventclass
-----------------------------------------
insert @tbl_columns values (1) -- textdata
--insert @tbl_columns values (2) -- binarydata
insert @tbl_columns values (3) -- databaseid
insert @tbl_columns values (4) -- transactionid
insert @tbl_columns values (5) -- linenumber
insert @tbl_columns values (6) -- ntusername
insert @tbl_columns values (8) -- hostname
insert @tbl_columns values (10) -- applicationname
insert @tbl_columns values (11) -- loginname
insert @tbl_columns values (12) -- spid
insert @tbl_columns values (13) -- duration
insert @tbl_columns values (14) -- starttime
insert @tbl_columns values (15) -- endtime
insert @tbl_columns values (16) -- reads
insert @tbl_columns values (17) -- writes
insert @tbl_columns values (18) -- cpu
insert @tbl_columns values (20) -- severity
insert @tbl_columns values (21) -- eventsubclass
insert @tbl_columns values (22) -- objectid
insert @tbl_columns values (24) -- indexid
insert @tbl_columns values (25) -- integerdata
insert @tbl_columns values (26) -- servername
insert @tbl_columns values (27) -- eventclass
insert @tbl_columns values (28) -- objecttype
insert @tbl_columns values (29) -- nestlevel
insert @tbl_columns values (30) -- state
insert @tbl_columns values (31) -- error
insert @tbl_columns values (32) -- mode
insert @tbl_columns values (34) -- objectname
insert @tbl_columns values (35) -- databasename
insert @tbl_columns values (48) -- rowcounts
insert @tbl_columns values (56) -- objectid2
insert @tbl_columns values (59) -- parentname

-----------------------------------------
--replace duration, server and share name
-----------------------------------------
set @on = 1

set @maxfilesize = 100 --in MBytes, will auto split when exceeding 100M

set @stop = dateadd(mi, @trace_runtime_in_min, getdate())

if right(@trace_file_folder, 1) = '\'
begin
	set @tracefilename = @trace_file_folder + 'tmwtrace~'
end
else
begin
	set @tracefilename = @trace_file_folder + '\tmwtrace~'
end

set @tracefilename = @tracefilename + replace(isnull(@@SERVERNAME, ''),'\','~') + '~' + replace(replace(convert(varchar(50),getdate(),120),':',''),' ','-')
set @tracefilename = @tracefilename + '~dur-' + convert(varchar(5),@trace_filter_duration_in_ms) + '~'
set @tracefilename = @tracefilename + convert(char(1),@completed_events)
set @tracefilename = @tracefilename + convert(char(1),@started_events)
set @tracefilename = @tracefilename + convert(char(1),@errors_warnings)
set @tracefilename = @tracefilename + convert(char(1),@locking_info)
set @tracefilename = @tracefilename + convert(char(1),@auto_stats)
set @tracefilename = @tracefilename + convert(char(1),@transaction_info)
set @tracefilename = @tracefilename + convert(char(1),@showplan_xml)

if @filter_spid > 0
set @tracefilename = @tracefilename + '~spid-' + convert(varchar(5),@filter_spid)

if @filter_loginname <> ''
set @tracefilename = @tracefilename + '~login-' + @filter_loginname

if @filter_application <> ''
set @tracefilename = @tracefilename + '~appl-' + @filter_application

exec @rc = sp_trace_create @TraceID output, 2, @tracefilename, @maxfilesize, @stop 
if (@rc != 0) goto error

-----------------------------------------
-- COMPLETED EVENTS
-----------------------------------------
if	@completed_events = 1
begin
	insert @tbl_eventclass values (10) -- RPC:Completed
	insert @tbl_eventclass values (12) -- SQL:BatchCompleted
	--insert @table_completed_events values (41) -- SQL:StmtCompleted
	insert @tbl_eventclass values (45) -- SP:StmtCompleted
end

-----------------------------------------
-- STARTED EVENTS
-----------------------------------------
if @started_events = 1
begin
	insert @tbl_eventclass values (11) -- RPC:Started
	insert @tbl_eventclass values (13) -- SQL:BatchStarted
	insert @tbl_eventclass values (40) -- SQL:StmtStarted
	insert @tbl_eventclass values (44) -- SP:StmtStarted
end

-----------------------------------------
-- ERRORS AND WARNINGS
-----------------------------------------
if @errors_warnings = 1
begin
insert @tbl_eventclass values (16) -- Attention
insert @tbl_eventclass values (20) -- Audit Login Failed
insert @tbl_eventclass values (21) -- EventLog
insert @tbl_eventclass values (22) -- ErrorLog
insert @tbl_eventclass values (25) -- Deadlock
insert @tbl_eventclass values (33) -- Exception
--insert @tbl_eventclass values (34) -- SP:CacheMiss
insert @tbl_eventclass values (37) -- SP: Recompile
--insert @tbl_eventclass values (54) -- Transaction Log Backup
insert @tbl_eventclass values (55) -- Hash Warning
insert @tbl_eventclass values (61) -- OLEDB Error
insert @tbl_eventclass values (67) -- Execution Warning
insert @tbl_eventclass values (69) -- Sort Warnings
insert @tbl_eventclass values (79) -- Missing Column Statistics
insert @tbl_eventclass values (80) -- Missing Join Predicate
insert @tbl_eventclass values (92) -- Data File Autogrow
insert @tbl_eventclass values (93) -- Log File Autogrow
insert @tbl_eventclass values (94) -- Data File Autoshrink
insert @tbl_eventclass values (95) -- Log File Autoshrink
insert @tbl_eventclass values (115) -- Backup/Restore 
insert @tbl_eventclass values (116) -- DBCC Event
insert @tbl_eventclass values (166) -- SP:StmtRecompile
end
-----------------------------------------
-- LOCKING INFO
-----------------------------------------
if @locking_info = 1
begin
	insert @tbl_eventclass values (24) -- Lock Acquired
	insert @tbl_eventclass values (60) -- Lock Escalation
end

-----------------------------------------
-- AUTO STATISTICS
-----------------------------------------
if @auto_stats = 1
begin
	insert @tbl_eventclass values (58) -- Auto Update Statistics
end

-----------------------------------------
-- TRANSACTION OPEN/CLOSE INFO
-----------------------------------------
if @transaction_info = 1
begin
	insert @tbl_eventclass values (50) -- Transaction Open/Close Events
end

-----------------------------------------
-- EXECUTION PLANS
-----------------------------------------
if @showplan_xml = 1
begin
	insert @tbl_eventclass values (122) -- ShowPlan XML Event
end

-----------------------------------------
-- Setup EventClasses & Columns to Capture in Trace
-----------------------------------------

DECLARE cur_eventclass CURSOR FORWARD_ONLY STATIC FOR 
SELECT eventclass
FROM @tbl_eventclass
ORDER BY eventclass

OPEN cur_eventclass

FETCH NEXT FROM cur_eventclass INTO @eventclass

WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE cur_columns CURSOR FORWARD_ONLY STATIC FOR 
	SELECT colid
	FROM @tbl_columns
	order by colid

	OPEN cur_columns
	FETCH NEXT FROM cur_columns INTO @columns

	WHILE @@FETCH_STATUS = 0
	BEGIN

		exec sp_trace_setevent @TraceID, @eventclass, @columns, @on

	FETCH NEXT FROM cur_columns INTO @columns
	END

	CLOSE cur_columns
	DEALLOCATE cur_columns

-- Get the next vendor.
FETCH NEXT FROM cur_eventclass INTO @eventclass

END 
CLOSE cur_eventclass
DEALLOCATE cur_eventclass


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'
set @bigintfilter = @trace_filter_duration_in_ms

If charindex('SQL Server 2005', @@version) > 0 or charindex('SQL Server 2008', @@version) > 0  --duration is in microseconds in sql 2005 / 2008
begin
	set @bigintfilter = @bigintfilter * 1000
end

/*
Enumerations for the sp_trace_setfilter procedure below

The 2nd parameter is the columnID
The 3rd parameter - 0 means AND, 1 means OR
The 4th parameter is the logical operand
0  = (Equal)
1  <> (Not Equal)
2  > (Greater Than)
3  < (Less Than)
4  >= (Greater Than Or Equal)
5  <= (Less Than Or Equal)
6  LIKE 
7  NOT LIKE 
*/

--Set Duration >= a Value
exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

-- Filter for LoginName if it was supplied
-- Set LoginName = a Value
If @filter_loginname <> ''
	exec sp_trace_setfilter @TraceID, 11, 0, 0, @filter_loginname

-- Filter for HostName if it was supplied
-- Set HostName = a Value
If @filter_hostname <> ''
	exec sp_trace_setfilter @TraceID, 8, 0, 0, @filter_hostname

-- Filter for ApplicationName if it was supplied
-- Set ApplicationName LIKE a Value
If @filter_application <> ''
	exec sp_trace_setfilter @TraceID, 10, 0, 6, @filter_application

-- Filter for ApplicationName if it was supplied
-- Set ApplicationName LIKE a Value
If @filter_spid > 0
	exec sp_trace_setfilter @TraceID, 12, 0, 0, @filter_spid

-- Set the trace status to start
  exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID, @tracefilename + '.trc', 'started at ' + convert(varchar(40),getdate()), 'will stop at ' + convert(varchar(40), @stop)
goto finish

error: 
select ErrorCode=@rc, case @rc 
		when 1 then 'ERROR: Unknown error.' 
		when 10 then 'ERROR: Invalid options. Returned when options specified are incompatible.'
		when 12 then 'ERROR: File could not be created. Make sure folder pre-exists.'
		when 13 then 'ERROR: Out of memory. Returned when there is not enough memory to perform the specified action.'
		when 14 then 'ERROR: Invalid stop time. Returned when the stop time specified has already happened.'
		when 15 then 'ERROR: Invalid parameters. Returned when the user supplied incompatible parameters.'
		else '' end

finish: 
GO
