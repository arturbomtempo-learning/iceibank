<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, useId, watch } from 'vue';

import mascotHead from '@/assets/mascot/mascot-head.webp';

const props = withDefaults(defineProps<{ covered?: boolean }>(), { covered: false });

const TURN_Y = 17;
const TURN_X = 12;
const SHIFT = 4.5;
const LIFT = 26;
const EASING = 0.12;

const cardGradientId = useId();

const root = ref<HTMLElement | null>(null);
const target = reactive({ x: 0, y: 0 });
const eased = reactive({ x: 0, y: 0 });

let frame = 0;

const headTransform = computed(
    () =>
        `translate3d(${(eased.x * SHIFT).toFixed(2)}%, ${(eased.y * SHIFT * 0.6).toFixed(2)}%, ${(
            (1 - Math.abs(eased.x)) *
            LIFT
        ).toFixed(1)}px)` +
        ` rotateY(${(eased.x * TURN_Y).toFixed(2)}deg)` +
        ` rotateX(${(-eased.y * TURN_X).toFixed(2)}deg)`
);

function clamp(value: number): number {
    return Math.min(1, Math.max(-1, value));
}

function handlePointer(event: PointerEvent): void {
    if (props.covered) return;

    const element = root.value;
    if (!element) return;

    const rect = element.getBoundingClientRect();
    if (rect.width === 0) return;

    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    const dx = event.clientX - centerX;
    const dy = event.clientY - centerY;

    target.x = clamp(dx / Math.max(dx >= 0 ? window.innerWidth - centerX : centerX, 1));
    target.y = clamp(dy / Math.max(dy >= 0 ? window.innerHeight - centerY : centerY, 1));
}

function tick(): void {
    eased.x += (target.x - eased.x) * EASING;
    eased.y += (target.y - eased.y) * EASING;
    frame = window.requestAnimationFrame(tick);
}

watch(
    () => props.covered,
    (covered) => {
        if (!covered) return;
        target.x = 0;
        target.y = 0.35;
    }
);

onMounted(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    window.addEventListener('pointermove', handlePointer, { passive: true });
    frame = window.requestAnimationFrame(tick);
});

onBeforeUnmount(() => {
    window.removeEventListener('pointermove', handlePointer);
    window.cancelAnimationFrame(frame);
});
</script>

<template>
    <div ref="root" class="mascot" :class="{ 'mascot--covered': covered }" aria-hidden="true">
        <div class="mascot__window">
            <div class="mascot__float">
                <div class="mascot__scene">
                    <img
                        :src="mascotHead"
                        width="320"
                        height="279"
                        alt=""
                        class="mascot__head"
                        :style="{ transform: headTransform }"
                    />
                </div>
            </div>

            <svg class="mascot__card" viewBox="0 0 224 141" fill="none">
                <defs>
                    <linearGradient :id="cardGradientId" x1="0" y1="0" x2="224" y2="141">
                        <stop offset="0%" stop-color="#11402f" />
                        <stop offset="100%" stop-color="#04211a" />
                    </linearGradient>
                </defs>

                <rect width="224" height="141" rx="14" :fill="`url(#${cardGradientId})`" />
                <rect
                    x="0.7"
                    y="0.7"
                    width="222.6"
                    height="139.6"
                    rx="13.3"
                    stroke="#2fc187"
                    stroke-opacity="0.32"
                    stroke-width="1.4"
                />

                <rect x="24" y="42" width="29" height="22" rx="5" fill="#cfd8d3" />
                <path
                    d="M24 53h29M38.5 42v22"
                    stroke="#11402f"
                    stroke-opacity="0.5"
                    stroke-width="1.5"
                />

                <g stroke="#8bb4a3" stroke-width="2.3" stroke-linecap="round">
                    <path d="M64 46a11 11 0 0 1 0 14" />
                    <path d="M71 41a19 19 0 0 1 0 24" />
                </g>

                <g transform="translate(24 90)">
                    <g transform="rotate(-45 11 11)">
                        <rect x="1" y="4" width="21" height="4.2" rx="2.1" fill="#ffffff" />
                        <rect
                            x="4"
                            y="11"
                            width="15"
                            height="4.2"
                            rx="2.1"
                            fill="#ffffff"
                            opacity="0.76"
                        />
                        <rect
                            x="7"
                            y="18"
                            width="9"
                            height="4.2"
                            rx="2.1"
                            fill="#ffffff"
                            opacity="0.52"
                        />
                    </g>
                    <text
                        x="33"
                        y="19"
                        fill="#ffffff"
                        font-family="'Plus Jakarta Sans', sans-serif"
                        font-size="18"
                        font-weight="800"
                        letter-spacing="-0.5"
                    >
                        ICEI
                        <tspan fill="#57e3a8">Bank</tspan>
                    </text>
                </g>
            </svg>
        </div>
    </div>
</template>

<style scoped>
.mascot {
    width: 100%;
    max-width: 17rem;
}

.mascot__window {
    position: relative;
    aspect-ratio: 1;
    overflow: hidden;
    border: 1px solid rgba(139, 180, 163, 0.32);
    border-radius: 30%;
    background:
        radial-gradient(120% 100% at 50% 0%, rgba(87, 227, 168, 0.12) 0%, transparent 62%),
        rgba(139, 180, 163, 0.07);
}

.mascot__float {
    position: absolute;
    inset: 0;
    display: grid;
    place-items: center;
    animation: mascot-float 7s ease-in-out infinite;
}

.mascot__scene {
    width: 84%;
    perspective: 480px;
}

.mascot__head {
    display: block;
    width: 100%;
    height: auto;
    transform-origin: 50% 62%;
    will-change: transform;
    filter: drop-shadow(0 16px 24px rgba(0, 0, 0, 0.32));
}

.mascot__card {
    position: absolute;
    left: 50%;
    top: 47%;
    width: 68%;
    transform: translate(-50%, 150%) rotate(10deg);
    opacity: 0;
    filter: drop-shadow(0 14px 26px rgba(0, 0, 0, 0.5));
    transition:
        transform 0.45s cubic-bezier(0.33, 1.3, 0.62, 1),
        opacity 0.18s ease;
}

.mascot--covered .mascot__card {
    transform: translate(-50%, -50%) rotate(-5deg);
    opacity: 1;
}

@keyframes mascot-float {
    0%,
    100% {
        transform: translateY(-1.5%);
    }
    50% {
        transform: translateY(1.5%);
    }
}

@media (prefers-reduced-motion: reduce) {
    .mascot__float {
        animation: none;
    }

    .mascot__card {
        transition: none;
    }
}
</style>
