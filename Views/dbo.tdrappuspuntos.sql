SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  view [dbo].[tdrappuspuntos]
as

select 
mpp_id as IdUsuario,
mpp_licensenumber as Password,
'Operador' as Tipo, 
mpp_cont_ded_nbr as Puntosconseguidos,
isnull(mpp_updt_cont_ded_nbr,0) as PuntosRestados,
(mpp_cont_ded_nbr) -  isnull(mpp_updt_cont_ded_nbr,0) as Puntaje,
mpp_exp2_enddate  as UltReset,
mpp_firstname as Nombre,
mpp_lastname as Apellidos
from manpowerprofile
where mpp_status <> 'OUT'

union

( select
'admin',
'admin',
'Sisadmin',
0,
0,
0,
null,
'Administrador',
'Del Sistema')
GO
