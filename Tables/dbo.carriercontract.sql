CREATE TABLE [dbo].[carriercontract]
(
[cct_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cct_contract_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_business_entity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_effective_dt] [datetime] NULL,
[cct_comments] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cct_updatedt] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_carriercontract] ON [dbo].[carriercontract]
FOR INSERT,UPDATE
AS
DECLARE @min_id		INTEGER,
        @tmwuser 	VARCHAR(255)
exec gettmwuser @tmwuser output

SET @min_id = 0
SELECT @min_id = MIN(cct_id)
  FROM inserted
 WHERE cct_id > @min_id

WHILE @min_id > 0 
BEGIN

   IF @min_id IS NULL
      BREAK

   UPDATE carriercontract
      SET cct_updatedby = @tmwuser,
          cct_updatedt = GETDATE()
    WHERE cct_id = @min_id

   SELECT @min_id = MIN(cct_id)
     FROM inserted
    WHERE cct_id > @min_id

END

GO
ALTER TABLE [dbo].[carriercontract] ADD CONSTRAINT [pk_carriercontract_cct_id] PRIMARY KEY CLUSTERED ([cct_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriercontract_car_id] ON [dbo].[carriercontract] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriercontract] TO [public]
GO
GRANT INSERT ON  [dbo].[carriercontract] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriercontract] TO [public]
GO
GRANT SELECT ON  [dbo].[carriercontract] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriercontract] TO [public]
GO
