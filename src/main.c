/********************************** (C) COPYRIGHT *******************************
* File Name          : main.c
* Version            : V1.0.0
* Date               : 2022/01/02
* Description        : msc ram test.
*******************************************************************************/

/*
 *@Note
*/
#include "debug.h"
#include "usbd_core.h"
#include "usbd_msc.h"

void usb_dc_low_level_init(void)
{
    RCC_USBCLK48MConfig(RCC_USBCLK48MCLKSource_USBPHY);
    RCC_USBHSPLLCLKConfig(RCC_HSBHSPLLCLKSource_HSE);
    RCC_USBHSConfig(RCC_USBPLL_Div2);
    RCC_USBHSPLLCKREFCLKConfig(RCC_USBHSPLLCKREFCLK_4M);
    RCC_USBHSPHYPLLALIVEcmd(ENABLE);
#ifdef CONFIG_USB_HS
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_USBHS, ENABLE);
#else
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_OTG_FS, ENABLE);
#endif

    Delay_Us(100);
#ifndef CONFIG_USB_HS
    //EXTEN->EXTEN_CTR |= EXTEN_USBD_PU_EN;
    NVIC_EnableIRQ(OTG_FS_IRQn);
#else
    NVIC_EnableIRQ( USBHS_IRQn );
#endif
}


/*********************************************************************
 * @fn      main
 *
 * @brief   Main program.
 *
 * @return  none
 */
int main(void)
{
    Delay_Init();
    USART_Printf_Init(115200);
    printf("SystemClk:%d\r\n", SystemCoreClock);

    Delay_Ms(10);

    extern void msc_ram_init(void);
    msc_ram_init();
    extern int usb_dc_init(void);
    usb_dc_init();

    while (!usb_device_is_configured()) {
    }
    while (1) {    
    }
}
