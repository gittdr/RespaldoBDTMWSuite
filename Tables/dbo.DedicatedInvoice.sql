CREATE TABLE [dbo].[DedicatedInvoice]
(
[DedicatedInvoiceId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedBillId] [int] NOT NULL,
[InvoiceId] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedInvoice_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedInvoice_CreatedBy] DEFAULT (user_name())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_DedicatedInvoice_audit]
ON [dbo].[DedicatedInvoice] FOR DELETE
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  DELETE trigger for DedicatedInvoice table for Expedite Audit functionality
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
    ,'DedicatedInvoice Deleted'
    ,'ivh_hdrnumber ' + CONVERT(VARCHAR(100), deleted.InvoiceId) 
     + ' removed from Dedicated Bill ' + CONVERT(VARCHAR(100), deleted.DedicatedBillId)
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

CREATE TRIGGER [dbo].[it_DedicatedInvoice_audit]
ON [dbo].[DedicatedInvoice] FOR INSERT
AS
SET NOCOUNT ON

/*******************************************************************************************************************  
  Object Description:
  INSERT trigger for DedicatedInvoice table for Expedite Audit functionality
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
    ,CONVERT(VARCHAR(100), inserted.DedicatedInvoiceId)
    ,0
    ,0
    ,'DedicatedInvoice'
    ,'DedicatedInvoice Created'
    ,'ivh_hdrnumber ' + CONVERT(VARCHAR(100), inserted.InvoiceId) 
     + ' added to Dedicated Bill ' + CONVERT(VARCHAR(100), inserted.DedicatedBillId)
    ,@tmwuser
    ,GETDATE()
  FROM inserted;
END;


SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[DedicatedInvoice] ADD CONSTRAINT [PK_DedicatedInvoice] PRIMARY KEY CLUSTERED ([DedicatedInvoiceId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedInvoice_DedicatedBillId] ON [dbo].[DedicatedInvoice] ([DedicatedBillId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedRateAllocation_DedicatedBillId] ON [dbo].[DedicatedInvoice] ([DedicatedBillId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedInvoice] ADD CONSTRAINT [FK_DedicatedInvoice_DedicatedBill] FOREIGN KEY ([DedicatedBillId]) REFERENCES [dbo].[DedicatedBill] ([DedicatedBillId])
GO
GRANT DELETE ON  [dbo].[DedicatedInvoice] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedInvoice] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedInvoice] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedInvoice] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedInvoice] TO [public]
GO
