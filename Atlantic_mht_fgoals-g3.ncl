load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;----------------------------------------------------------------------
; Procedure to attach a box to the given plot, given the lower left
; corner, width, color(cname), and opacity.
;----------------------------------------------------------------------
procedure add_box(wks,plot,ll[2],widthx,widthy,cname,oval)
local xbox, ybox, gsres, dumstr
begin
  xbox = (/ll(0),ll(0)+widthx,ll(0)+widthx,ll(0),ll(0)/)
  ybox = (/ll(1),ll(1),ll(1)+widthy,ll(1)+widthy,ll(1)/)

  gsres                = True
  gsres@gsFillColor    = cname
  gsres@gsFillOpacityF = oval
  dumstr               = unique_string("gon")
;
; Adding it as an attribute is a sneaky way to
; make sure it "lives" outside this procedure.
;
  plot@$dumstr$ = gsn_add_polygon(wks,plot,xbox,ybox,gsres)
end
;*******************************************************************
; plot atlantic northward heat transport 
;********************************************************************
begin

pi         = 3.14159265359
d2rad      = 0.01745329
R0         = 6371393.0
rad        = (pi/180.)
p0         = 1029.0
cp         = 3996.0

lev1 = (/0, -10, -20, -30, -40, -50, -60, -70, -80, -90, -100, -110, -120, -130, -140, -150, -163.8606, -192.9948, -252.0088, -354.2027, -510.9896, -731.3966, -1021.67, -1385.003, -1821.396, -2327.656, -2897.536, -3522.009, -4189.662, -4887.194, -5600/)

plot_format = "x11"
plot_name   = "./Atlantic_mht_fgoals-g3"
plot_color  = "ncl_default" ;"BlWhRe" ;"MPL_bwr" ;"MPL_seismic" ;"MPL_bwr" ;"NCV_jet" ;"BlueDarkRed18"

;************************************ Global basin *******************************************

fin1               = addfile("/data05/linpf/FGOALS-g3/data/MM_1To12-ee14d-6ensmean.nc","r")
mth1               = fin1->mth_adv(:,0,:,1);[time | 12] x [tracer_dim | 2] x [lat_aux | 316] x [basin | 2]
printVarSummary(mth1)
mth11              = fin1->mth_adv_iso(:,0,:,1); [time | 12] x [tracer_dim | 2] x [lat_aux | 316] x [basin | 2]

mth_time_lat             = mth1
mth_time_lat             = mth1+mth11 ; euler indeuced + eddy induced heat transport
printVarSummary(mth_time_lat)
time = fin1->time

lat_aux = fin1->lat_aux
printVarSummary(lat_aux)
nlat  = dimsizes(lat_aux)
;**************** compute climatology **********************
mth_lat       = new((/nlat/), typeof(mth1), 0) ;missing value is 0 rather than others
mth_lat       = dim_avg_n(mth_time_lat, 0) ; ->(lat)
;print(mth_lat)

mth_lat@longname = " meridional heat transport(lat) "
mth_lat@units = "PW" ;
;*********** mth standard deviation ****************
mth_lat_std = new((/nlat/), typeof(mth1), mth1@_FillValue)
mth_lat_std = dim_stddev_n(mth_time_lat, 0)
;*********** mth cliamology +/- std *******************
mth_lat_minus_std = mth_lat
mth_lat_minus_std = mth_lat-mth_lat_std

mth_lat_plus_std = mth_lat
mth_lat_plus_std = mth_lat+mth_lat_std
;***************************************
  xp    = new( (/2*nlat/), double, mth1@_FillValue)
 yp    = new( (/2*nlat/), typeof(mth1), mth1@_FillValue)
 do k=0,nlat-1

   yp(k)          = mth_lat(k)+mth_lat_std(k)
   xp(k)          = lat_aux(k)
   xp(2*nlat-1-k) = lat_aux(k)
   yp(2*nlat-1-k) = mth_lat(k)-mth_lat_std(k)
 end do
;**************************
lines1             = new((/7,dimsizes(lat_aux)/),"float",mth11@_FillValue)
lines1(0,:)        = mth_lat
lines1(1,:)        = mth_lat_plus_std
lines1(2,:)        = mth_lat_minus_std
;lines1(3,:)        = mth44
;lines1(4,:)        = mth55
;lines1(5,:)        = mth66
;lines1(6,:)        = mth88
;lines1!1           = "lat_aux"
;lines1&lat_aux     = mth11&lat_aux
;printVarSummary(lines1)
;print(lines1(:,{24.0}))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wks        = gsn_open_wks(plot_format,plot_name)
gsn_define_colormap(wks,plot_color)
;plot       = new(3,graphic)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

res                                 = True
res@gsnDraw                         = False
res@gsnFrame                        = False
res@vpWidthF                        = 0.6
res@vpHeightF                       = 0.4
res@trXMinF                         =-33.0
res@trXMaxF                         = 90.0

res@pmLegendDisplayMode             = "Never"            ; turn off legend

;res@gsnXRefLine                    = (/-70,-65,-60,-55,-50,-45,-40,-35.0/)
;res@gsnXRefLineDashPattern         = 2
;res@gsnXRefLineThicknessF          = 1.0
;res@gsnXRefLineColor               = "gray42"

res@tiXAxisFont                     = "times-roman"
res@tiYAxisFont                     = "times-roman"
res@tiXAxisFontHeightF              = 0.015
res@tiYAxisFontHeightF              = 0.015
; res@tiXAxisString                   = "Latitude"
;res@tiMainString                    = "Global"

res@tmXTOn                          = False
res@tmYROn                          = False
res@tmXBLabelFont                   = "times-roman"
res@tmYLLabelFont                   = "times-roman"
res@tmXBLabelFontHeightF            = 0.014
res@tmYLLabelFontHeightF            = 0.014
res@tmXBLabelsOn                    = True
res@tmXBMajorLengthF                = 0.02
res@tmYLMajorLengthF                = 0.001

; res@tmXBMajorThicknessF                 = 0.1
res@tmXBMode                        = "Explicit"
res@tmXBValues                      = (/-80,-60,-40,-20,0,20,40,60,80.0/)
res@tmXBLabels                      = (/"80~S~o~N~S","60~S~o~N~S","40~S~o~N~S","20~S~o~N~S","0~S~o","20~S~o~N~N","40~S~o~N~N","60~S~o~N~N","80~S~o~N~N"/)
res@tmXBMinorValues                 = fspan(-80,90,18)
res@tmYLMode                        = "Explicit"
;res@gsnYAxisIrregular2Linear=True
;res@gsnXAxisIrregular2Linear=True
res@tmXBLabelFont                        = "times-roman"
res@tmYLLabelFont                        = "times-roman"
res@gsnStringFont                        = "times-roman"
res@lbLabelFont                          = "times-roman"
res@lbTitleFont                          = "times-roman"
res@tiYAxisFont                          = "times-roman"
res@tiXAxisFont                          = "times-roman"

; res@gsnLeftStringOrthogonalPosF     =-0.10
res@gsnLeftStringParallelPosF       = 0.01
res@gsnCenterStringOrthogonalPosF   = 0.01
res@gsnRightStringOrthogonalPosF    = 0.01
res@gsnLeftStringFontHeightF        = 0.015
res@gsnCenterStringFontHeightF      = 0.015
res@gsnRightStringFontHeightF       = 0.015
res@gsnLeftString                   = "(d) Atlantic"
res@gsnCenterString                 = ""
res@gsnRightString                  = ""

res1                                = res
res1@trYMinF                        =-1.5
res1@trYMaxF                        = 2
res1@vpXF                           = 0.18
res1@vpYF                           = 0.80
res1@tmYLValues                     = (/-1.5,-1.0,-0.5,0,0.5,1.0,1.5/)
res1@tmYLLabels                     = (/-1.5,-1.0,-0.5,0,0.5,1.0,1.5/)+""
res1@gsnYRefLine                    = (/-1.5,-1.0,-0.5,0,0.5,1.0,1.5/)

res1@gsnYRefLineDashPatterns        = (/2,2,2,0,2,2,2/)
res1@gsnYRefLineThicknesses         = (/1.0,1.0,1.0,2.0,1.0,1.0,1.0/)
res1@gsnYRefLineColors              = (/"gray42","gray42","gray42","gray42","gray42","gray42","gray42"/)
res1@xyDashPatterns                 = (/0,0,0,0,0,0,0/)
res1@xyLineThicknesses              = (/3.0,3.0,3.0,3.0,3.0,3.0,3.0/)

;res1@xyLineColor                   = (/"forestgreen"/)
res1@xyLineColor                   = (/"red"/)
res1@tiYAxisString                  = "Northward Heat Transport (PW)"
; res1@gsnLeftString                  = ""
plot                                = gsn_csm_xy(wks,mth11&lat_aux,lines1(0,:),res1)
;res1@xyLineColors                   = (/"gray11","magenta","dodgerblue","yellow","red","seagreen2","orangered","turquoise1"/)
;res1@xyLineColor                   = (/"red"/)
;plot1                               = gsn_csm_xy(wks,mth22&lat_aux,lines1(1,:),res1)
;overlay(plot,plot1)
;******************** add nht 2 sigma **************************************************
 gsres                   = True                        ; poly res
 gsres@tfPolyDrawOrder   = "Predraw"                   ; draw this first
 gsres@gsFillColor       = "SlateBlue"                 ; color chosen
 gsres@gsFillColor       = "gray" 
 ;dummy = gsn_add_polygon (wks,plot,xp,yp,gsres)


;***************************
pres                                = True
pres@gsLineThicknessF               = 3.0
pres@gsLineColor                    = "gray11"
;dum1                                = gsn_add_polyline(wks,plot,(/-25,-15/),(/-0.2,-0.2/),pres)
pres@gsLineColor                    = "magenta"
;dum2                                = gsn_add_polyline(wks,plot,(/0,10/),   (/-0.2,-0.2/),pres)
pres@gsLineColor                    = "dodgerblue"
;dum3                                = gsn_add_polyline(wks,plot,(/25,35/),  (/-0.2,-0.2/),pres)
pres@gsLineColor                    = "yellow"
;dum4                                = gsn_add_polyline(wks,plot,(/50,60/),  (/-0.2,-0.2/),pres)
pres@gsLineColor                    = "red"
;dum5                                = gsn_add_polyline(wks,plot,(/-25,-15/),(/-0.5,-0.5/),pres)
pres@gsLineColor                    = "gray11"
;dum6                                = gsn_add_polyline(wks,plot,(/45,65/),   (/-0.5,-0.5/),pres)
;pres@gsLineColor                    = "forestgreen"

;pres@gsLineColor                    = "red"
;dum7                                = gsn_add_polyline(wks,plot,(/55,65/),  (/-0.5,-0.5/),pres)
;pres@gsLineColor                    = "turquoise1"
;dum8                                = gsn_add_polyline(wks,plot,(/50,60/),  (/-0.5,-0.5/),pres)
;pres@gsLineColor                    = "blue"
;dum8                                = gsn_add_polyline(wks, plot, (/47,57/), (/-0.5,-0.5/),pres)

txres                               = True
txres@txFontHeightF                 = 0.012
txres@txFont                        = "times-roman"
;txres@txBackgroundFillColor         = "transparent"
;addtext1                            = gsn_add_text(wks,plot,"CTL",       -9,-0.2,txres)
;addtext2                            = gsn_add_text(wks,plot,"BCK",       16,-0.2,txres)
;addtext3                            = gsn_add_text(wks,plot,"BCKN2adj",  41,-0.2,txres)
;addtext4                            = gsn_add_text(wks,plot,"N2adj",     66,-0.2,txres)
;addtext5                            = gsn_add_text(wks,plot,"noGMn2",    -9,-0.5,txres)
;addtext6                            = gsn_add_text(wks,plot,"COREII",    29,-0.5,txres)
;addtext7                            = gsn_add_text(wks,plot,"JRA55",    72,-0.5,txres)
;addtext8                            = gsn_add_text(wks,plot,"+/-1 sigma",     -47,1.3,txres)

gsres=True              ; Indicate you want to set some resources.
gsres@gsMarkerColor=1   ; Change marker color.
gsres@gsMarkerSizeF=14. ; Increase marker size by a factor of 10.
gsres@gsMarkerThicknessF = 5
gsres@gsMarkerIndex=4   ; Change marker type to a filled circle.

;*********** add gray color-index(polygon)
;add_box(wks,plot,(/-70,1.2/),10,0.2,"gray",    1.0)


position_heat=(/-29,-20,-10,-8,8,22,47/)
heat=(/0.35,0.7,0.89,1.05,1.4,1.39,0.68/)
dum0 = gsn_add_polymarker(wks,plot,position_heat,heat,gsres)
gsn_polymarker_ndc(wks,position_heat,heat,gsres)  ; Draw the polymarkers.
;addMaker                            = gsn_add_polymarker(wks, plot, 53, -0.5, gsres)
draw(plot)

frame(wks)


end














