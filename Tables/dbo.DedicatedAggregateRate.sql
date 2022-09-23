CREATE TABLE [dbo].[DedicatedAggregateRate]
(
[DedicatedAggregateRateId] [int] NOT NULL IDENTITY(1, 1),
[TariffId] [int] NOT NULL,
[ContractId] [int] NOT NULL,
[FormulaSourceId] [int] NOT NULL,
[PreDefinedFormulaId] [int] NULL,
[StoredProcedureName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllocateToInvoices] [bit] NOT NULL,
[InvoiceAllocationById] [int] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Dedicated__Creat__4A77B3AD] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Dedicated__Creat__4B6BD7E6] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Dedicated__LastU__4C5FFC1F] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__Dedicated__LastU__4D542058] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_DedicatedAggregateRate_audit]
ON [dbo].[DedicatedAggregateRate] FOR DELETE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  DELETE trigger for DedicatedAggregateRate table for Expedite Audit functionality
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
    ,'AggregateRate Deleted'
    ,'Contract ID: ' + CONVERT(VARCHAR(100), d.ContractId)
     + ' TariffId: ' + CONVERT(VARCHAR(100), d.TariffId)
     + ' FormulaSource: ''' + rfs.[Name] + ''''
     + ' Formula: ''' + (CASE WHEN ISNULL(d.PreDefinedFormulaId, 0) = 0 THEN d.StoredProcedureName ELSE pdf.[Name] END) + ''''
     + ' Allocate: ' + CONVERT(VARCHAR(100), d.AllocateToInvoices)
     + ' Allocate By: ''' + (CASE WHEN ISNULL(d.InvoiceAllocationById, 0) = 0 THEN '<not set>' ELSE iab.[Name] END) + ''''
    ,@tmwuser
    ,GETDATE()
  FROM deleted d
    JOIN AggregateRateFormulaSource rfs (NOLOCK) ON rfs.AggregateRateFormulaSourceId = d.FormulaSourceId
    LEFT JOIN AggregateRatePreDefinedFormula pdf (NOLOCK) ON pdf.AggregateRatePreDefinedFormulaId = d.PreDefinedFormulaId
    LEFT JOIN InvoiceAllocationBy iab (NOLOCK) ON iab.InvoiceAllocationById = d.InvoiceAllocationById;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_DedicatedAggregateRate_audit]
ON [dbo].[DedicatedAggregateRate] FOR INSERT
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  INSERT trigger for DedicatedAggregateRate table for Expedite Audit functionality
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
    ,'AggregateRate Created'
    ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
     + ' TariffId: ' + CONVERT(VARCHAR(100), i.TariffId)
     + ' FormulaSource: ''' + rfs.[Name] + ''''
     + ' Formula: ''' + (CASE WHEN ISNULL(i.PreDefinedFormulaId, 0) = 0 THEN i.StoredProcedureName ELSE pdf.[Name] END) + ''''
     + ' Allocate: ' + CONVERT(VARCHAR(100), i.AllocateToInvoices)
     + ' Allocate By: ''' + (CASE WHEN ISNULL(i.InvoiceAllocationById, 0) = 0 THEN '<not set>' ELSE iab.[Name] END) + ''''
    ,@tmwuser
    ,GETDATE()
  FROM inserted i
    JOIN AggregateRateFormulaSource rfs (NOLOCK) ON rfs.AggregateRateFormulaSourceId = i.FormulaSourceId
    LEFT JOIN AggregateRatePreDefinedFormula pdf (NOLOCK) ON pdf.AggregateRatePreDefinedFormulaId = i.PreDefinedFormulaId
    LEFT JOIN InvoiceAllocationBy iab (NOLOCK) ON iab.InvoiceAllocationById = i.InvoiceAllocationById;
END;


SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_DedicatedAggregateRate_audit]
ON [dbo].[DedicatedAggregateRate] FOR UPDATE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  UPDATE trigger for DedicatedAggregateRate table for Expedite Audit functionality
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

  IF UPDATE(TariffId)
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
      ,'AggregateRate Update'
      ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
       + ' TariffId: ' + CONVERT(VARCHAR(100), d.TariffId) + ' -> ' + CONVERT(VARCHAR(100), i.TariffId)
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedAggregateRateId = d.DedicatedAggregateRateId
    WHERE i.TariffId <> d.TariffId;
  END;

  IF UPDATE(FormulaSourceId)
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
      ,'AggregateRate Update'
      ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
       + ' TariffId: ' + CONVERT(VARCHAR(100), i.TariffId) 
       + ' FormulaSource: ''' + drfs.[Name] + ''' -> ''' + irfs.[Name] + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedAggregateRateId = d.DedicatedAggregateRateId
      JOIN AggregateRateFormulaSource drfs (NOLOCK) ON drfs.AggregateRateFormulaSourceId = d.FormulaSourceId
      JOIN AggregateRateFormulaSource irfs (NOLOCK) ON irfs.AggregateRateFormulaSourceId = i.FormulaSourceId
    WHERE i.FormulaSourceId <> d.FormulaSourceId;
  END;

  IF UPDATE(StoredProcedureName)
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
      ,'AggregateRate Update'
      ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
       + ' TariffId: ' + CONVERT(VARCHAR(100), i.TariffId)
       + ' StoredProcedureName: ''' + ISNULL(d.StoredProcedureName, '<not set>') + ''' -> ''' + ISNULL(i.StoredProcedureName, '<not set>') + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedAggregateRateId = d.DedicatedAggregateRateId
    WHERE ISNULL(i.StoredProcedureName, '<not set>') <> ISNULL(d.StoredProcedureName, '<not set>');
  END;

  IF UPDATE(PreDefinedFormulaId)
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
      ,'AggregateRate Update'
      ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
       + ' TariffId: ' + CONVERT(VARCHAR(100), i.TariffId)
       + ' PreDefinedFormula: ''' + ISNULL(dpdf.[Name], '<not set>') + ''' -> ''' + ISNULL(ipdf.[Name], '<not set>') + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedAggregateRateId = d.DedicatedAggregateRateId
      LEFT JOIN AggregateRatePreDefinedFormula dpdf (NOLOCK) ON dpdf.AggregateRatePreDefinedFormulaId = d.PreDefinedFormulaId
      LEFT JOIN AggregateRatePreDefinedFormula ipdf (NOLOCK) ON ipdf.AggregateRatePreDefinedFormulaId = i.PreDefinedFormulaId
    WHERE ISNULL(i.PreDefinedFormulaId, -1) <> ISNULL(d.PreDefinedFormulaId, -1);
  END;

  IF UPDATE(AllocateToInvoices)
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
      ,'AggregateRate Update'
      ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
       + ' TariffId: ' + CONVERT(VARCHAR(100), i.TariffId)
       + ' AllocateToInvoices: ' + CONVERT(VARCHAR(100), d.AllocateToInvoices) + ' -> ' + CONVERT(VARCHAR(100), i.AllocateToInvoices)
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedAggregateRateId = d.DedicatedAggregateRateId
    WHERE i.AllocateToInvoices <> d.AllocateToInvoices;
  END;

  IF UPDATE(InvoiceAllocationById)
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
      ,'AggregateRate Update'
      ,'Contract ID: ' + CONVERT(VARCHAR(100), i.ContractId)
       + ' TariffId: ' + CONVERT(VARCHAR(100), i.TariffId)
       + ' Allocation: ''' + ISNULL(dab.[Name], '<not set>') + ''' -> ''' + ISNULL(iab.[Name], '<not set>') + ''''
      ,@tmwuser
      ,GETDATE()
    FROM inserted i
      JOIN deleted d ON i.DedicatedAggregateRateId = d.DedicatedAggregateRateId
      LEFT JOIN InvoiceAllocationBy dab (NOLOCK) ON dab.InvoiceAllocationById = d.InvoiceAllocationById
      LEFT JOIN InvoiceAllocationBy iab (NOLOCK) ON iab.InvoiceAllocationById = i.InvoiceAllocationById
    WHERE ISNULL(i.InvoiceAllocationById, -1) <> ISNULL(d.InvoiceAllocationById, -1);
  END;


END;


SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[DedicatedAggregateRate] ADD CONSTRAINT [PK_DedicatedAggregateRate] PRIMARY KEY CLUSTERED ([DedicatedAggregateRateId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedAggregateRate_ContractId] ON [dbo].[DedicatedAggregateRate] ([ContractId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedAggregateRate] ADD CONSTRAINT [FK_DedicatedAggregateRate_AggregateRateFormulaSource] FOREIGN KEY ([FormulaSourceId]) REFERENCES [dbo].[AggregateRateFormulaSource] ([AggregateRateFormulaSourceId])
GO
ALTER TABLE [dbo].[DedicatedAggregateRate] ADD CONSTRAINT [FK_DedicatedAggregateRate_AggregateRatePreDefinedFormula] FOREIGN KEY ([PreDefinedFormulaId]) REFERENCES [dbo].[AggregateRatePreDefinedFormula] ([AggregateRatePreDefinedFormulaId])
GO
ALTER TABLE [dbo].[DedicatedAggregateRate] ADD CONSTRAINT [FK_DedicatedAggregateRate_DedicatedContract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[DedicatedContract] ([ContractId])
GO
ALTER TABLE [dbo].[DedicatedAggregateRate] ADD CONSTRAINT [FK_DedicatedAggregateRate_tariffheader] FOREIGN KEY ([TariffId]) REFERENCES [dbo].[tariffheader] ([tar_number])
GO
GRANT DELETE ON  [dbo].[DedicatedAggregateRate] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedAggregateRate] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedAggregateRate] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedAggregateRate] TO [public]
GO
