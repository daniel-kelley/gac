/************************************************************************
 IMPORTANT NOTE : this file contains two clearly delimited sections :
 the ARCHITECTURE section (in two parts) and the USER section. Each section
 is governed by its own copyright and license. Please check individually
 each section for license and copyright information.
 *************************************************************************/

/*******************BEGIN ARCHITECTURE SECTION (part 1/2)****************/

/************************************************************************
 FAUST Architecture File
 Copyright (C) 2003-2019 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This Architecture section is free software; you can redistribute it
 and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3 of
 the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; If not, see <http://www.gnu.org/licenses/>.

 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.

 ************************************************************************
 ************************************************************************/

/* GAC test driver derived from faust/architecture/minimal.c */

#define _GNU_SOURCE
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <fenv.h>

#include "faust/gui/CInterface.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

/******************************************************************************
 *******************************************************************************

 VECTOR INTRINSICS

 *******************************************************************************
 *******************************************************************************/

<<includeIntrinsic>>

/********************END ARCHITECTURE SECTION (part 1/2)****************/

/**************************BEGIN USER SECTION **************************/

<<includeclass>>

/***************************END USER SECTION ***************************/

/*******************BEGIN ARCHITECTURE SECTION (part 2/2)***************/

#define BUFFER_SIZE 64
#define SAMPLE_RATE 44100

static UIGlue ui;

static float rand_range(float dmin, float dmax)
{
    float delta = dmax - dmin;
    float fval = dmin + ((float)drand48() * delta);
    return fval;
}

static float rand_bool(void)
{
    float fval =((float)drand48() < 0.5f);
    return fval;
}

static void test_openTabBox(void* ui_interface, const char* label)
{
}

static void test_openHorizontalBox(void* ui_interface, const char* label)
{
}

static void test_openVerticalBox(void* ui_interface, const char* label)
{
}

static void test_closeBox(void* ui_interface)
{
}

static void test_addButton(void* ui_interface, const char* label, FAUSTFLOAT* zone)
{
    *zone = rand_bool();
}

static void test_addCheckButton(void* ui_interface, const char* label, FAUSTFLOAT* zone)
{
    *zone = rand_bool();
}

static void test_addVerticalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    *zone = rand_range(min,max);
}

static void test_addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    *zone = rand_range(min,max);
}

static void test_addNumEntry(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    *zone = rand_range(min,max);
}

static void test_addHorizontalBargraph(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max)
{
    *zone = rand_range(min,max);
}

static void test_addVerticalBargraph(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max)
{
    *zone = rand_range(min,max);
}

static void test_addSoundfile(void* ui_interface, const char* label, const char* url, struct Soundfile** sf_zone)
{
}

static void test_declare(void* ui_interface, FAUSTFLOAT* zone, const char* key, const char* value)
{
}

static void init_ui(UIGlue *ui)
{
    ui->uiInterface = ui;
    ui->openTabBox = test_openTabBox;
    ui->openHorizontalBox = test_openHorizontalBox;
    ui->openVerticalBox = test_openVerticalBox;
    ui->closeBox = test_closeBox;
    ui->addButton = test_addButton;
    ui->addCheckButton = test_addCheckButton;
    ui->addVerticalSlider = test_addVerticalSlider;
    ui->addHorizontalSlider = test_addHorizontalSlider;
    ui->addNumEntry = test_addNumEntry;
    ui->addHorizontalBargraph = test_addHorizontalBargraph;
    ui->addVerticalBargraph = test_addVerticalBargraph;
    ui->addSoundfile = test_addSoundfile;
    ui->declare = test_declare;
}

/* Breakpointable place */
void wait(void)
{
}

int main(int argc, char* argv[])
{
    mydsp* dsp = newmydsp();
    int num_inputs = getNumInputsmydsp(dsp);
    int num_outputs = getNumOutputsmydsp(dsp);
    int c;
    unsigned long seed = rand();
    unsigned long count = 1000;
    unsigned long wait_count = 0;
    while ((c = getopt(argc, argv, "n:s:w:")) != EOF) {
        switch (c) {
        case 'n':
            count = strtoul(optarg,0,0);
            break;
        case 'w':
            wait_count = strtoul(optarg,0,0);
            break;
        case 's':
            seed = strtoul(optarg,0,0);
            break;
        default:
            break;
        }
    }

    printf("Seed: %lu\n", seed);
    // Init with audio driver SR
    initmydsp(dsp, SAMPLE_RATE);
    init_ui(&ui);

    // add one to work around scan-build complaint for zero length VLA
    FAUSTFLOAT* inputs[num_inputs+1];
    FAUSTFLOAT* outputs[num_outputs+1];
    for (int chan = 0; chan < num_inputs; ++chan) {
        inputs[chan] = malloc(sizeof(FAUSTFLOAT) * BUFFER_SIZE);
    }
    for (int chan = 0; chan < num_outputs; ++chan) {
        outputs[chan] = malloc(sizeof(FAUSTFLOAT) * BUFFER_SIZE);
    }
    feenableexcept(FE_DIVBYZERO | FE_INVALID |FE_OVERFLOW);
    // Compute a buffer
    while (count--) {
        if (count == wait_count) {
            wait();
        }
        buildUserInterfacemydsp(dsp, &ui);
        computemydsp(dsp, BUFFER_SIZE, inputs, outputs);
        feclearexcept(FE_ALL_EXCEPT);
    }
    for (int chan = 0; chan < num_inputs; ++chan) {
        free(inputs[chan]);
    }
    for (int chan = 0; chan < num_outputs; ++chan) {
        free(outputs[chan]);
    }
    deletemydsp(dsp);

    return 0;
}

/********************END ARCHITECTURE SECTION (part 2/2)****************/
