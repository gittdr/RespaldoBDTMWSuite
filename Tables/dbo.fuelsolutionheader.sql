CREATE TABLE [dbo].[fuelsolutionheader]
(
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[opt_fuel_purchased] [int] NULL,
[tot_actual_cost] [decimal] (7, 2) NULL,
[act_cost_gal] [decimal] (6, 4) NULL,
[act_cost_mile] [decimal] (6, 4) NULL,
[tot_eff_cost] [decimal] (7, 2) NULL,
[eff_cost_gal] [decimal] (6, 4) NULL,
[eff_cost_mile] [decimal] (6, 4) NULL,
[total_savings] [decimal] (7, 2) NULL,
[saving_gal] [decimal] (7, 4) NULL,
[saving_mile] [decimal] (7, 4) NULL,
[avg_cost_gal] [decimal] (6, 4) NULL,
[request_id] [int] NULL,
[fuelsolutionhdr_id] [int] NOT NULL IDENTITY(1, 1),
[route_max] [decimal] (6, 4) NULL,
[route_min] [decimal] (6, 4) NULL,
[retail_average] [decimal] (6, 4) NULL,
[retail_max] [decimal] (6, 4) NULL,
[retail_min] [decimal] (6, 4) NULL,
[vehicle_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retail_avg] [decimal] (8, 4) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_fuelsolutionheader] ON [dbo].[fuelsolutionheader] FOR INSERT 
AS
DECLARE @fingerprintaudit 	CHAR(1),
        @tmwuser                VARCHAR(255),
	@UseTripAudit		CHAR(1)

EXEC gettmwuser @tmwuser OUT

SELECT @fingerprintaudit = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
  FROM generalinfo
 WHERE gi_name = 'fingerprintaudit'

SELECT @UseTripAudit = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
  FROM generalinfo
 WHERE gi_name = 'UseTripAudit'

IF @fingerprintaudit = 'Y' AND @UseTripAudit = 'Y'
BEGIN
   INSERT INTO expedite_audit (ord_hdrnumber, mov_number, lgh_number, activity, update_note,
		               join_to_table_name, key_value, updated_by, updated_dt)
      SELECT l.ord_hdrnumber,
             l.mov_number, 
             l.lgh_number,
             'Fuel Solution Rcvd',
             '',
             'fuelsolutionheader',
             i.fuelsolutionhdr_id,
             @tmwuser, 
             GETDATE()
        FROM inserted i JOIN legheader l ON i.lgh_number = l.lgh_number
END

GO
ALTER TABLE [dbo].[fuelsolutionheader] ADD CONSTRAINT [pk_fuelsolutionheader ] UNIQUE NONCLUSTERED ([lgh_number], [request_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelsolutionheader] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelsolutionheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelsolutionheader] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelsolutionheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelsolutionheader] TO [public]
GO
