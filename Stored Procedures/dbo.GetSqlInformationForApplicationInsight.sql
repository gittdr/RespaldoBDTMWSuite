SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[GetSqlInformationForApplicationInsight]
AS
BEGIN
	
/***************************************************************************
TMW Operations Phone home logic


Name              Version  Date        Release Notes
------------------- -------- ----------- --------------------------------
Eric Blinn          v1.0     2015-04-08  Initial Release

***************************************************************************/
SET NOCOUNT ON;

DECLARE 
  @SQL NVARCHAR(4000) 
, @majorversion TINYINT 
, @PerfConterObjectName NVARCHAR(256) 
, @ServerStartDate DATETIME 
, @virtual_machine_type_value sysname 
, @virtual_machine_type_desc_Value sysname 
, @Open_User_Connections INTEGER 
, @TargetServerMem INTEGER 
, @TotalServerMem INTEGER 
, @ProcessorNameString_Value sysname 
, @OsName sysname
, @SqlEdition VARCHAR(1000)
, @SqlBrief_version VARCHAR(1000)
, @SqlSP_Level VARCHAR(1000)
, @WIndowsStartDate sysname
, @CoreSystemInfo sysname
, @Server_CPU_Count TINYINT
, @Server_HyperThread_Ratio TINYINT
, @Collation sysname
, @OUTPUTXML XML
, @DatabaseConnections INT
, @SqlString NVARCHAR(1000);

SET @Collation = CAST(SERVERPROPERTY(N'Collation') AS sysname);
SET @OsName = SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14);
SET @SqlBrief_version = CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(1000));
SET @SqlEdition = CAST(SERVERPROPERTY('Edition') AS VARCHAR(1000));
SET @SqlSP_Level = CAST(SERVERPROPERTY('ProductLevel') AS VARCHAR(1000));
SET @majorversion = LEFT(CONVERT(VARCHAR(20), SERVERPROPERTY('ProductVersion')),
                         CHARINDEX('.',
                                   CONVERT(VARCHAR(20), SERVERPROPERTY('ProductVersion')))
                         - 1);


-- get the CPU Info
SELECT
    @Server_CPU_Count = [cpu_count]
  , @Server_HyperThread_Ratio = [hyperthread_ratio]
  FROM
    [sys].[dm_os_sys_info]; 


-- Get the Total and Target server Memory
SELECT
    @TargetServerMem = ( [cntr_value] / 1024 )
  FROM
    [sys].[dm_os_performance_counters]
  WHERE
    [counter_name] = 'Target Server Memory (KB)';

SELECT
    @TotalServerMem = ( [cntr_value] / 1024 )
  FROM
    [sys].[dm_os_performance_counters]
  WHERE
    [counter_name] = 'Total Server Memory (KB)';


-- Get the Server Start time, virtual_machine_type and virtual_machine_type_desc
IF @majorversion = 10
BEGIN
  SELECT 
    @ServerStartDate = sqlserver_start_time 
  , @virtual_machine_type_value = ''
  , @virtual_machine_type_desc_Value = ''
	FROM
    sys.dm_os_sys_info;
END  
ELSE IF @majorversion >= 11
BEGIN
  SET @SqlString = 'SELECT '
  SET @SqlString += '@ServerStartDate = sqlserver_start_time'
  SET @SqlString += ', @virtual_machine_type_value = virtual_machine_type'
  SET @SqlString += ', @virtual_machine_type_desc_Value = virtual_machine_type_desc'
  SET @SqlString += ' FROM sys.dm_os_sys_info;'

  EXEC sp_executesql @SqlString, N'@ServerStartDate DATETIME OUT, @virtual_machine_type_value sysname OUT, @virtual_machine_type_desc_Value sysname OUT',
									 @ServerStartDate out, @virtual_machine_type_value out, @virtual_machine_type_desc_Value out
END
ELSE
BEGIN
  SELECT 
    @ServerStartDate = create_date
  , @virtual_machine_type_value = ''
  , @virtual_machine_type_desc_Value = ''
  FROM 
    sys.databases 
  WHERE 
    name = 'TempDB'
END;


IF @@SERVICENAME = 'MSSQLSERVER'
  SET @PerfConterObjectName = 'SQLServer';
ELSE
  SET @PerfConterObjectName = 'MSSQL$' + @@SERVICENAME;


SELECT
  @Open_User_Connections = [cntr_value]
FROM
  [sys].[dm_os_performance_counters]
WHERE
  [object_name] = @PerfConterObjectName + N':General Statistics'
    AND 
  [counter_name] = 'User Connections';

    

SELECT
  @DatabaseConnections = COUNT([dbid])
FROM
  [sys].[sysprocesses]
WHERE
  [dbid] > 0
    AND 
  DB_NAME([dbid]) = DB_Name();
 

SELECT  
  'TMWDB' AS DBType, DB_Name()AS DBName
, SUM(CASE WHEN SDF.type in ( 0, 2, 4 ) THEN size/128 ELSE 0 END) AS DataFileSizeMB
, SUM(CASE WHEN NOT SDF.type in ( 0, 2, 4 ) THEN size/128 ELSE 0 END) AS LogFileSizeMB
, SUM(CASE WHEN SDF.type in ( 0, 2, 4 ) THEN 1 ELSE 0 END) DataFileCount 
, COUNT(DISTINCT SDF.data_space_id) - 1 DataFileGroupCount
, SD.compatibility_level AS Compatibility_Level
, SD.recovery_model_desc AS Recovery_Model 
, CAST(@DatabaseConnections AS VARCHAR(10)) AS DatabaseConnections 
, @@SERVERNAME AS [Server_Name]
, @@VERSION AS [Server_Version]
, @SqlBrief_version AS [SQL_VERSION_SHORT]
, @SqlEdition AS [SQL_Edition]
, @SqlSP_Level AS [SQL_SP_Level]
, @majorversion AS [MajorVersion]
, @OsName AS [OSName]
, CAST(GETDATE() AS VARCHAR) AS [RunOn]
, @ServerStartDate AS [DBServer_Start]
, @virtual_machine_type_value AS [VMT]
, @virtual_machine_type_desc_Value AS [VMT_Description]
, @Open_User_Connections AS [Open_User_Connections]
, @Server_CPU_Count AS [Server_CPU_Count]
, @Server_HyperThread_Ratio AS [Server_HyperThread_Ratio]
, @TargetServerMem AS [Target_server_Memory]
, @TotalServerMem AS [Total_server_Memory]
, @Collation AS [Collation]
FROM sys.database_files SDF CROSS JOIN sys.dm_os_sys_info OSIF
  CROSS JOIN sys.databases SD WHERE SD.name = db_name()
GROUP BY 
  SD.compatibility_level
, SD.recovery_model_desc
, SD.[Compatibility_Level]
, SD.[Recovery_Model]   

END
GO
GRANT EXECUTE ON  [dbo].[GetSqlInformationForApplicationInsight] TO [public]
GO
