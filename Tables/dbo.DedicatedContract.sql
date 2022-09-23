CREATE TABLE [dbo].[DedicatedContract]
(
[ContractId] [int] NOT NULL IDENTITY(1, 1),
[BillToId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractStart] [datetime] NOT NULL,
[ContractEnd] [datetime] NULL,
[BillUseDate] [int] NOT NULL,
[ScheduleId] [int] NOT NULL,
[OutputRestrictionId] [int] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Dedicated__Creat__394D27AB] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Dedicated__Creat__3A414BE4] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Dedicated__LastU__3B35701D] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__Dedicated__LastU__3C299456] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_DedicatedContract_audit]
ON [dbo].[DedicatedContract] FOR DELETE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  DELETE trigger for DedicatedContract table for Expedite Audit functionality
  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  2017/12/12   AV               NSUITE-202957  Creation of trigger
********************************************************************************************************************/

DECLARE @ls_audit BIT;

/*
GENERAL INFO MASTER LOOKUP BEGIN
*/

DECLARE @GI_VALUES_TO_LOOKUP TABLE (
  gi_name VARCHAR(30) PRIMARY KEY);

DECLARE @GIKEY TABLE (
  gi_name     VARCHAR(30) PRIMARY KEY
 ,gi_string1  VARCHAR(60)
 ,gi_string2  VARCHAR(60)
 ,gi_string3  VARCHAR(60)
 ,gi_string4  VARCHAR(60)
 ,gi_integer1 INT
 ,gi_integer2 INT
 ,gi_integer3 INT
 ,gi_integer4 INT);

INSERT 
  @GI_VALUES_TO_LOOKUP
VALUES
  ('FingerprintAudit')
;  

INSERT INTO @GIKEY (gi_name
, gi_string1
, gi_string2
, gi_string3
, gi_string4
, gi_integer1
, gi_integer2
, gi_integer3
, gi_integer4)
SELECT 
  gi_name
 ,gi_string1
 ,gi_string2
 ,gi_string3
 ,gi_string4
 ,gi_integer1
 ,gi_integer2
 ,gi_integer3
 ,gi_integer4
FROM (
      SELECT 
        gvtlu.gi_name
       ,g.gi_string1
       ,g.gi_string2
       ,g.gi_string3 
       ,g.gi_string4
       ,gi_integer1
       ,gi_integer2
       ,gi_integer3
       ,gi_integer4
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
       ,ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE COALESCE(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g on gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1; --   <---This is how we take the top 1.

/*
GENERAL INFO MASTER LOOKUP END
*/

SELECT @ls_audit = CASE WHEN COALESCE(UPPER(SUBSTRING(gi_string1, 1, 1)), 'N') = 'Y' THEN 1 ELSE 0 END
FROM @GIKEY
WHERE gi_name = 'FingerprintAudit';


IF @ls_audit = 1
BEGIN
  DECLARE @tmwuser VARCHAR(255);
  EXEC gettmwuser @tmwuser OUTPUT;

  INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
  SELECT
     0
    ,CONVERT(VARCHAR(100), d.ContractId)
    ,0
    ,0
    ,'DedicatedContract'
    ,'DedicatedContract Deleted'
    ,'Contract ID: ' + CONVERT(VARCHAR(100), d.ContractId)
     + ' BillTo: ''' + d.BillToId + ''''
     + ' Desc: ''' + d.[Description] + ''''
     + ' Starts: ' + FORMAT(d.ContractStart, 'yyyy-MM-dd')
     + ' Ends: ' + FORMAT(d.ContractEnd, 'yyyy-MM-dd')
    ,@tmwuser
    ,GETDATE()
  FROM deleted d
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_DedicatedContract_audit]
ON [dbo].[DedicatedContract] FOR INSERT
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  INSERT trigger for DedicatedContract table for Expedite Audit functionality
  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  2017/12/12   AV               NSUITE-202957  Creation of trigger
********************************************************************************************************************/

DECLARE @ls_audit BIT;

/*
GENERAL INFO MASTER LOOKUP BEGIN
*/

DECLARE @GI_VALUES_TO_LOOKUP TABLE (
  gi_name VARCHAR(30) PRIMARY KEY);

DECLARE @GIKEY TABLE (
  gi_name     VARCHAR(30) PRIMARY KEY
 ,gi_string1  VARCHAR(60)
 ,gi_string2  VARCHAR(60)
 ,gi_string3  VARCHAR(60)
 ,gi_string4  VARCHAR(60)
 ,gi_integer1 INT
 ,gi_integer2 INT
 ,gi_integer3 INT
 ,gi_integer4 INT);

INSERT 
  @GI_VALUES_TO_LOOKUP
VALUES
  ('FingerprintAudit')
;  

INSERT INTO @GIKEY (gi_name
, gi_string1
, gi_string2
, gi_string3
, gi_string4
, gi_integer1
, gi_integer2
, gi_integer3
, gi_integer4)
SELECT 
  gi_name
 ,gi_string1
 ,gi_string2
 ,gi_string3
 ,gi_string4
 ,gi_integer1
 ,gi_integer2
 ,gi_integer3
 ,gi_integer4
FROM (
      SELECT 
        gvtlu.gi_name
       ,g.gi_string1
       ,g.gi_string2
       ,g.gi_string3 
       ,g.gi_string4
       ,gi_integer1
       ,gi_integer2
       ,gi_integer3
       ,gi_integer4
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
       ,ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE COALESCE(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g on gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1; --   <---This is how we take the top 1.

/*
GENERAL INFO MASTER LOOKUP END
*/

SELECT @ls_audit = CASE WHEN COALESCE(UPPER(SUBSTRING(gi_string1, 1, 1)), 'N') = 'Y' THEN 1 ELSE 0 END
FROM @GIKEY
WHERE gi_name = 'FingerprintAudit';


IF @ls_audit = 1
BEGIN
  DECLARE @tmwuser VARCHAR(255);
  EXEC gettmwuser @tmwuser OUTPUT;

  INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
  SELECT
     0
    ,CONVERT(VARCHAR(100), i.ContractId)
    ,0
    ,0
    ,'DedicatedContract'
    ,'DedicatedContract Created'
    ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
     + ' BillTo: ''' + i.BillToId + ''''
     + ' Desc: ''' + i.[Description] + ''''
     + ' Starts: ' + FORMAT(i.ContractStart, 'yyyy-MM-dd')
     + ' Ends: ' + FORMAT(i.ContractEnd, 'yyyy-MM-dd')
    ,@tmwuser
    ,GETDATE()
  FROM inserted i;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_DedicatedContract_audit]
ON [dbo].[DedicatedContract] FOR UPDATE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  UPDATE trigger for DedicatedContract table for Expedite Audit functionality
  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  2017/12/12   AV               NSUITE-202957  Creation of trigger
********************************************************************************************************************/

DECLARE @ls_audit BIT;

/*
GENERAL INFO MASTER LOOKUP BEGIN
*/

DECLARE @GI_VALUES_TO_LOOKUP TABLE (
  gi_name VARCHAR(30) PRIMARY KEY);

DECLARE @GIKEY TABLE (
  gi_name     VARCHAR(30) PRIMARY KEY
 ,gi_string1  VARCHAR(60)
 ,gi_string2  VARCHAR(60)
 ,gi_string3  VARCHAR(60)
 ,gi_string4  VARCHAR(60)
 ,gi_integer1 INT
 ,gi_integer2 INT
 ,gi_integer3 INT
 ,gi_integer4 INT);

INSERT 
  @GI_VALUES_TO_LOOKUP
VALUES
  ('FingerprintAudit')
;  

INSERT INTO @GIKEY (gi_name
, gi_string1
, gi_string2
, gi_string3
, gi_string4
, gi_integer1
, gi_integer2
, gi_integer3
, gi_integer4)
SELECT 
  gi_name
 ,gi_string1
 ,gi_string2
 ,gi_string3
 ,gi_string4
 ,gi_integer1
 ,gi_integer2
 ,gi_integer3
 ,gi_integer4
FROM (
      SELECT 
        gvtlu.gi_name
       ,g.gi_string1
       ,g.gi_string2
       ,g.gi_string3 
       ,g.gi_string4
       ,gi_integer1
       ,gi_integer2
       ,gi_integer3
       ,gi_integer4
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
       ,ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE COALESCE(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g on gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1; --   <---This is how we take the top 1.

/*
GENERAL INFO MASTER LOOKUP END
*/

SELECT @ls_audit = CASE WHEN COALESCE(UPPER(SUBSTRING(gi_string1, 1, 1)), 'N') = 'Y' THEN 1 ELSE 0 END
FROM @GIKEY
WHERE gi_name = 'FingerprintAudit';


IF @ls_audit = 1
BEGIN
  DECLARE @tmwuser VARCHAR(255);
  EXEC gettmwuser @tmwuser OUTPUT;

  IF UPDATE(BillToId)
  BEGIN
    INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
    SELECT
       0
      ,CONVERT(VARCHAR(100), i.ContractId)
      ,0
      ,0
      ,'DedicatedContract'
      ,'DedicatedContract Update'
      ,'BillToId: ''' + d.BillToId + ''' -> ''' + i.BillToId + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.ContractId = d.ContractId
    WHERE i.BillToId <> d.BillToId;
  END;

  IF UPDATE([Description])
  BEGIN
    INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
    SELECT
       0
      ,CONVERT(VARCHAR(100), i.ContractId)
      ,0
      ,0
      ,'DedicatedContract'
      ,'DedicatedContract Update'
      ,'Description: ''' + d.[Description] + ''' -> ''' + i.[Description] + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.ContractId = d.ContractId
    WHERE i.[Description] <> d.[Description];
  END;

  IF UPDATE(ContractStart)
  BEGIN
    INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
    SELECT
       0
      ,CONVERT(VARCHAR(100), i.ContractId)
      ,0
      ,0
      ,'DedicatedContract'
      ,'DedicatedContract Update'
      ,'ContractStart: ' + FORMAT(d.ContractStart, 'yyyy-MM-dd') + ' -> ' + FORMAT(i.ContractStart, 'yyyy-MM-dd')
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.ContractId = d.ContractId
    WHERE i.ContractStart <> d.ContractStart;
  END;

  IF UPDATE(ContractEnd)
  BEGIN
    INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
    SELECT
       0
      ,CONVERT(VARCHAR(100), i.ContractId)
      ,0
      ,0
      ,'DedicatedContract'
      ,'DedicatedContract Update'
      ,'ContractEnd: ' + FORMAT(d.ContractEnd, 'yyyy-MM-dd') + ' -> ' + FORMAT(i.ContractEnd, 'yyyy-MM-dd')
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.ContractId = d.ContractId
    WHERE i.ContractEnd <> d.ContractEnd;
  END;

  IF UPDATE(BillUseDate)
  BEGIN
    INSERT INTO expedite_audit
    (ord_hdrnumber
    ,key_value
    ,mov_number
    ,lgh_number
    ,join_to_table_name
    ,activity
    ,update_note
    ,updated_by
    ,updated_dt)
    SELECT
       0
      ,CONVERT(VARCHAR(100), i.ContractId)
      ,0
      ,0
      ,'DedicatedContract'
      ,'DedicatedContract Update'
      ,'BillUseDate: ''' + dBillUseDate.[Name] + ''' -> ''' + iBillUseDate.[Name] + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.ContractId = d.ContractId
      JOIN DedicatedContractBillUseDate dBillUseDate (NOLOCK) ON dBillUseDate.DedicatedContractBillUseDateId = d.BillUseDate
      JOIN DedicatedContractBillUseDate iBillUseDate (NOLOCK) ON iBillUseDate.DedicatedContractBillUseDateId = i.BillUseDate
    WHERE i.BillUseDate <> d.BillUseDate;
  END;

END;


SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[DedicatedContract] ADD CONSTRAINT [PK_DedicatedContract] PRIMARY KEY CLUSTERED ([ContractId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedContract_BillToId] ON [dbo].[DedicatedContract] ([BillToId], [ContractStart], [ContractEnd]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedContract] ADD CONSTRAINT [FK_DedicatedContract_DedicatedContractBillUseDate] FOREIGN KEY ([BillUseDate]) REFERENCES [dbo].[DedicatedContractBillUseDate] ([DedicatedContractBillUseDateId])
GO
ALTER TABLE [dbo].[DedicatedContract] ADD CONSTRAINT [FK_DedicatedContract_Schedules] FOREIGN KEY ([ScheduleId]) REFERENCES [dbo].[Schedules] ([ScheduleId])
GO
GRANT DELETE ON  [dbo].[DedicatedContract] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedContract] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedContract] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedContract] TO [public]
GO
