CREATE TABLE [dbo].[DedicatedDetail]
(
[DedicatedDetailId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedBillId] [int] NOT NULL,
[ItemCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity] [decimal] (9, 4) NOT NULL,
[Rate] [decimal] (19, 4) NOT NULL,
[RateFactor] [decimal] (9, 4) NOT NULL,
[Amount] [decimal] (19, 4) NOT NULL,
[TariffId] [int] NOT NULL,
[DetailDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BasisUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailSource] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sign] [smallint] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedDetail_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedDetail_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FixValue] [tinyint] NULL,
[ArTaxAuthority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailType] [int] NULL CONSTRAINT [DF__Dedicated__Detai__68F93F3B] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_DedicatedDetail_audit]
ON [dbo].[DedicatedDetail] FOR DELETE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  DELETE trigger for DedicatedDetail table for Expedite Audit functionality
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
    ,CONVERT(VARCHAR(100), deleted.DedicatedBillId)
    ,0
    ,0
    ,'DedicatedBill'
    ,'DedicatedDetail Deleted'
    ,'Bill ID: ' + CONVERT(VARCHAR(100), deleted.DedicatedBillId) 
     + ' ItemCode: ''' + deleted.ItemCode + ''''
     + ' Qty: ' +  CONVERT(VARCHAR(100), deleted.Quantity)
     + ' Rt: ' +  CONVERT(VARCHAR(100), deleted.Rate)
     + ' Amnt: ' +  CONVERT(VARCHAR(100), deleted.Amount)
    ,@tmwuser
    ,GETDATE()
  FROM deleted;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_DedicatedDetail_audit]
ON [dbo].[DedicatedDetail] FOR INSERT
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  INSERT trigger for DedicatedDetail table for Expedite Audit functionality
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
    ,CONVERT(VARCHAR(100), DedicatedDetailId)
    ,0
    ,0
    ,'DedicatedDetail'
    ,'DedicatedDetail Created'
    ,'Bill ID: ' + CONVERT(VARCHAR(100), inserted.DedicatedBillId) 
     + ' ItemCode: ''' + inserted.ItemCode + ''''
     + ' Qty: ' +  CONVERT(VARCHAR(100), inserted.Quantity)
     + ' Rt: ' +  CONVERT(VARCHAR(100), inserted.Rate)
     + ' Amnt: ' +  CONVERT(VARCHAR(100), inserted.Amount)
    ,@tmwuser
    ,GETDATE()
  FROM inserted;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_DedicatedDetail_audit]
ON [dbo].[DedicatedDetail] FOR UPDATE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  UPDATE trigger for DedicatedDetail table for Expedite Audit functionality
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

  IF UPDATE(ItemCode)
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
      ,CONVERT(VARCHAR(100), i.DedicatedDetailId)
      ,0
      ,0
      ,'DedicatedDetail'
      ,'DedicatedDetail Update'
      ,'ItemCode: ''' + d.ItemCode + ''' -> ''' + i.ItemCode + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedDetailId = d.DedicatedDetailId
    WHERE i.ItemCode <> d.ItemCode;
  END;

  IF UPDATE(Quantity)
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
      ,CONVERT(VARCHAR(100), i.DedicatedDetailId)
      ,0
      ,0
      ,'DedicatedDetail'
      ,'DedicatedDetail Update'
      ,'Quantity: ' + CONVERT(VARCHAR(100), d.Quantity) + ' -> ' + CONVERT(VARCHAR(100), i.Quantity)
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedDetailId = d.DedicatedDetailId
    WHERE i.Quantity <> d.Quantity;
  END;

  IF UPDATE(Rate)
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
      ,CONVERT(VARCHAR(100), i.DedicatedDetailId)
      ,0
      ,0
      ,'DedicatedDetail'
      ,'DedicatedDetail Update'
      ,'Rate: ' + CONVERT(VARCHAR(100), d.Rate) + ' -> ' + CONVERT(VARCHAR(100), i.Rate)
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedDetailId = d.DedicatedDetailId
    WHERE i.Rate <> d.Rate;
  END;

  IF UPDATE(Amount)
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
      ,CONVERT(VARCHAR(100), i.DedicatedDetailId)
      ,0
      ,0
      ,'DedicatedDetail'
      ,'DedicatedDetail Update'
      ,'Amount: ' + CONVERT(VARCHAR(100), d.Amount) + ' -> ' + CONVERT(VARCHAR(100), i.Amount)
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedDetailId = d.DedicatedDetailId
    WHERE i.Amount <> d.Amount;
  END;

END;


SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[DedicatedDetail] ADD CONSTRAINT [PK_DedicatedDetail] PRIMARY KEY CLUSTERED ([DedicatedDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedDetail_DedicatedBillId] ON [dbo].[DedicatedDetail] ([DedicatedBillId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedDetail_TariffId] ON [dbo].[DedicatedDetail] ([TariffId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedDetail] ADD CONSTRAINT [FK_DedicatedDetail_DedicatedBill] FOREIGN KEY ([DedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
ALTER TABLE [dbo].[DedicatedDetail] ADD CONSTRAINT [FK_DedicatedDetail_DedicatedDetailType] FOREIGN KEY ([DetailType]) REFERENCES [dbo].[DedicatedDetailType] ([DedicatedDetailTypeId])
GO
GRANT DELETE ON  [dbo].[DedicatedDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedDetail] TO [public]
GO
