CREATE TABLE [dbo].[DedicatedBill]
(
[DedicatedBillId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedMasterId] [int] NOT NULL,
[DedicatedStatusId] [int] NOT NULL,
[BillDate] [datetime] NOT NULL,
[DedicatedTypeId] [int] NOT NULL,
[DedicatedBillOutputRestrictionId] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedBill_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedBill_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_DedicatedBill_audit]
ON [dbo].[DedicatedBill] FOR DELETE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  DELETE trigger for DedicatedBill table for Expedite Audit functionality
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
    ,CONVERT(VARCHAR(100), DedicatedBillId)
    ,0
    ,0
    ,'DedicatedBill'
    ,'DedicatedBill Deleted'
    ,'Master ID: ' + CONVERT(VARCHAR(100), d.DedicatedMasterId)
     + ' Type: ''' + dt.[Name] + ''''
     + ' Status: ''' + ds.[Name] + ''''
     + ' Bill Date: ' + FORMAT(d.BillDate, 'yyyy-MM-dd')
    ,@tmwuser
    ,GETDATE()
  FROM deleted d
    JOIN DedicatedType dt (NOLOCK) ON dt.DedicatedTypeId = d.DedicatedTypeId
    JOIN DedicatedStatus ds (NOLOCK) ON ds.DedicatedStatusId = d.DedicatedStatusId;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_DedicatedBill_audit]
ON [dbo].[DedicatedBill] FOR INSERT
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  INSERT trigger for DedicatedBill table for Expedite Audit functionality
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
    ,CONVERT(VARCHAR(100), DedicatedBillId)
    ,0
    ,0
    ,'DedicatedBill'
    ,'DedicatedBill Created'
    ,'Master ID: ' + CONVERT(VARCHAR(100), i.DedicatedMasterId)
     + ' Type: ''' + dt.[Name] + ''''
     + ' Status: ''' + ds.[Name] + ''''
     + ' Bill Date: ' + FORMAT(i.BillDate, 'yyyy-MM-dd')
    ,@tmwuser
    ,GETDATE()
  FROM inserted i
    JOIN DedicatedType dt (NOLOCK) ON dt.DedicatedTypeId = i.DedicatedTypeId
    JOIN DedicatedStatus ds (NOLOCK) ON ds.DedicatedStatusId = i.DedicatedStatusId;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_DedicatedBill_audit]
ON [dbo].[DedicatedBill] FOR UPDATE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  UPDATE trigger for DedicatedBill table for Expedite Audit functionality
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

  IF UPDATE(BillDate)
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
      ,CONVERT(VARCHAR(100), i.DedicatedBillId)
      ,0
      ,0
      ,'DedicatedBill'
      ,'DedicatedBill Update'
      ,'BillDate: ' + FORMAT(d.BillDate, 'yyyy-MM-dd') + ' -> ' + FORMAT(i.BillDate, 'yyyy-MM-dd')
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedBillId = d.DedicatedBillId
    WHERE i.BillDate <> d.BillDate;
  END;

  
  IF UPDATE(DedicatedStatusId)
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
      ,CONVERT(VARCHAR(100), i.DedicatedBillId)
      ,0
      ,0
      ,'DedicatedBill'
      ,'DedicatedBill Update'
      ,'Status: ''' + dds.[Name] + ''' -> ''' + ids.[Name] + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedBillId = d.DedicatedBillId
      JOIN DedicatedStatus ids ON ids.DedicatedStatusId = i.DedicatedStatusId
      JOIN DedicatedStatus dds ON dds.DedicatedStatusId = d.DedicatedStatusId
    WHERE i.DedicatedStatusId <> d.DedicatedStatusId;
  END;
END;


SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[DedicatedBill] ADD CONSTRAINT [PK_DedicatedBill] PRIMARY KEY CLUSTERED ([DedicatedBillId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedBill_DedicatedMasterId] ON [dbo].[DedicatedBill] ([DedicatedMasterId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedBill] ADD CONSTRAINT [FK_DedicatedBill_DedicatedBillOutputRestriction_DedicatedBillOutputRestrictionId] FOREIGN KEY ([DedicatedBillOutputRestrictionId]) REFERENCES [dbo].[DedicatedBillOutputRestriction] ([DedicatedBillOutputRestrictionId])
GO
ALTER TABLE [dbo].[DedicatedBill] ADD CONSTRAINT [FK_DedicatedBill_DedicatedMaster] FOREIGN KEY ([DedicatedMasterId]) REFERENCES [dbo].[DedicatedMaster] ([DedicatedMasterId])
GO
ALTER TABLE [dbo].[DedicatedBill] ADD CONSTRAINT [FK_DedicatedBill_DedicatedStatus] FOREIGN KEY ([DedicatedStatusId]) REFERENCES [dbo].[DedicatedStatus] ([DedicatedStatusId])
GO
ALTER TABLE [dbo].[DedicatedBill] ADD CONSTRAINT [FK_DedicatedBill_DedicatedType] FOREIGN KEY ([DedicatedTypeId]) REFERENCES [dbo].[DedicatedType] ([DedicatedTypeId])
GO
GRANT DELETE ON  [dbo].[DedicatedBill] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedBill] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedBill] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedBill] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedBill] TO [public]
GO
