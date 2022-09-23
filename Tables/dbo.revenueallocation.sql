CREATE TABLE [dbo].[revenueallocation]
(
[ral_id] [int] NOT NULL IDENTITY(1, 1),
[ivh_number] [int] NULL,
[ivd_number] [int] NULL,
[lgh_number] [int] NULL,
[thr_id] [int] NULL,
[ral_proratequantity] [money] NULL,
[ral_totalprorates] [money] NULL,
[ral_rate] [money] NULL,
[ral_amount] [money] NULL,
[cur_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_conversion_rate] [money] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_sequence] [int] NULL,
[ral_converted_rate] [money] NULL,
[ral_converted_amount] [money] NULL,
[ral_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_created_date] [datetime] NULL,
[ral_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_modified_date] [datetime] NULL,
[ral_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_chtrule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_distindex] [int] NULL,
[ral_prorateitem] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_debit_amount] [money] NULL,
[ral_credit_amount] [money] NULL,
[ral_distribution_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_inv_debit_amount] [money] NULL,
[ral_inv_credit_amount] [money] NULL,
[ral_system_debit_amount] [money] NULL,
[ral_system_credit_amount] [money] NULL,
[AccountingTaxId] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[it_revenueallocation] on [dbo].[revenueallocation] for insert 
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	05/25/2006	Greg Kanzinger PTS 32396: Added functionality to update the created/modified user/datetime fields.
*/

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

update revenueallocation 
set 	ral_created_date  = getdate (), 
	ral_created_user = @tmwuser,
	ral_modified_date = getdate (),
	ral_modified_user = @tmwuser
from inserted
where revenueallocation.ral_id = inserted.ral_id

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_revenueallocation] on [dbo].[revenueallocation] for update 
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	05/25/2006	Greg Kanzinger PTS 32396: Added functionality to update the created/modified user/datetime fields.
*/

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

update revenueallocation 
set 	ral_modified_date = getdate (),
	ral_modified_user = @tmwuser
from inserted
where revenueallocation.ral_id = inserted.ral_id

GO
ALTER TABLE [dbo].[revenueallocation] ADD CONSTRAINT [pk_revenueallocation_id] PRIMARY KEY CLUSTERED ([ral_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [revall_ivd] ON [dbo].[revenueallocation] ([ivd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ral_ivhnum] ON [dbo].[revenueallocation] ([ivh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[revenueallocation] TO [public]
GO
GRANT INSERT ON  [dbo].[revenueallocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[revenueallocation] TO [public]
GO
GRANT SELECT ON  [dbo].[revenueallocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[revenueallocation] TO [public]
GO
