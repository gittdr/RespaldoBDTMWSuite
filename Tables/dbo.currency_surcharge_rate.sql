CREATE TABLE [dbo].[currency_surcharge_rate]
(
[csr_billto_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csr_to_billto_cex_rate] [money] NOT NULL,
[csr_surcharge_multiplier] [float] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[iut_currency_surcharge_rate] ON [dbo].[currency_surcharge_rate]
FOR  INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	----------------------------------------
	08/13/2003	Vern Jewett		19494	(none)	Original.
*/

--Round csr_surcharge_multiplier (float) to 6 decimals.  PowerBuilder is trying to
--compare a 6-digit decimal to a database value which is different if taken out past
--6 decimal places.  Hence, it's wrecking PB's optimistic concurrency control, and we
--are getting "Row changed between retrieve and update" errors..
update	currency_surcharge_rate
  set	csr_surcharge_multiplier = round(i.csr_surcharge_multiplier, 6)
  from	currency_surcharge_rate csr
		,inserted i
  where	csr.csr_billto_currency = i.csr_billto_currency
	and	csr.csr_to_billto_cex_rate = i.csr_to_billto_cex_rate
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_currency_surcharge_rate] ON [dbo].[currency_surcharge_rate] ([csr_billto_currency], [csr_to_billto_cex_rate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[currency_surcharge_rate] TO [public]
GO
GRANT INSERT ON  [dbo].[currency_surcharge_rate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[currency_surcharge_rate] TO [public]
GO
GRANT SELECT ON  [dbo].[currency_surcharge_rate] TO [public]
GO
GRANT UPDATE ON  [dbo].[currency_surcharge_rate] TO [public]
GO
