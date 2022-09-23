SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[TDRGO_Sp_obtiene_pagos] (@Usuario varchar(100) )
AS
SET NOCOUNT ON
SELECT TOP 10  cast( PYH_PYHNUMBER as varchar(10)) as PayNumber,
        CONVERT(char(18), PYH_PAYPERIOD,126) + '0.0000+00:00'  as PayPeriod,
       '$' + dbo.fnc_TMWRN_FormatNumbers(PYH_TOTALCOMP+pyh_totaldeduct+pyh_totalreimbrs,2)  as Amount
 FROM [PAYHEADER]
 WHERE
   ASGN_ID = @Usuario
   and pyh_paystatus in ('XFR','REL')
   order by  PYH_PAYPERIOD desc
GO
