CREATE TABLE [dbo].[DedicatedContractRestriction]
(
[RestrictionId] [int] NOT NULL IDENTITY(1, 1),
[ContractId] [int] NOT NULL,
[LabelDefinition] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Dedicated__Creat__54011DE7] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Dedicated__Creat__54F54220] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Dedicated__LastU__55E96659] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__Dedicated__LastU__56DD8A92] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_DedicatedContractRestriction_audit]
ON [dbo].[DedicatedContractRestriction] FOR DELETE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  DELETE trigger for DedicatedContractRestriction table for Expedite Audit functionality
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
    ,'ContractRestriction Deleted'
    ,'Contract ID: ' + CONVERT(VARCHAR(100), d.ContractId)
     + ' LabelDefinition: ''' + d.LabelDefinition + ''''
     + ' Restriction: ''' + d.[Value] + ''''
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

CREATE TRIGGER [dbo].[it_DedicatedContractRestriction_audit]
ON [dbo].[DedicatedContractRestriction] FOR INSERT
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  INSERT trigger for DedicatedContractRestriction table for Expedite Audit functionality
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
    ,'ContractRestriction Created'
    ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
     + ' LabelDefinition: ''' + i.LabelDefinition + ''''
     + ' Restriction: ''' + i.[Value] + ''''
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

CREATE TRIGGER [dbo].[ut_DedicatedContractRestriction_audit]
ON [dbo].[DedicatedContractRestriction] FOR UPDATE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  UPDATE trigger for DedicatedContractRestriction table for Expedite Audit functionality
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

  IF UPDATE(LabelDefinition)
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
      ,'ContractRestriction Update'
      ,'LabelDefinition: ''' + d.LabelDefinition + ''' -> ''' + i.LabelDefinition + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.RestrictionId = d.RestrictionId
    WHERE i.LabelDefinition <> d.LabelDefinition;
  END;

  IF UPDATE([Value])
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
      ,'ContractRestriction Update'
      ,'Value: ''' + d.[Value] + ''' -> ''' + i.[Value] + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.RestrictionId = d.RestrictionId
    WHERE i.[Value] <> d.[Value];
  END;
END;


SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[DedicatedContractRestriction] ADD CONSTRAINT [PK_DedicatedContractRestriction] PRIMARY KEY CLUSTERED ([RestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedContractRestriction_ContractId] ON [dbo].[DedicatedContractRestriction] ([ContractId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedContractRestriction] ADD CONSTRAINT [FK_DedicatedContractRestriction_DedicatedContract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[DedicatedContract] ([ContractId])
GO
GRANT DELETE ON  [dbo].[DedicatedContractRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedContractRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedContractRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedContractRestriction] TO [public]
GO
